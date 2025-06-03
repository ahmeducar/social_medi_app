import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone_app/models/comment.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/models/user.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //* kullanıcı profili 
  Future<void> saveUserInfoInFirebase({
    //* get current uid
    required String name,email
    }
  )async{
    String uid =_auth.currentUser!.uid;

    //! extract username from email 
    String username = email.split('@')[0];
    //? create a user profile
    UserProfile user = UserProfile(
      bio: '',
      uid: uid,
      name: name,
      email: email, 
      username: username 
    );

    //! convert user into a map so that we can store n firebase

    final userMap = user.toMap();

    //* save the user profile to firebase
    await _db.collection("Users").doc(uid).set(userMap);
  

}

  //? get user info 
  Future<UserProfile?> getUserFromFirebase(String uid)async{
    try{
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      return UserProfile.fromDocument(userDoc);
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  //! update user bio
  Future<void> updateUserBioInfoFirebase(String bio)async{
    String uid = AuthService().getCurrentUid();
    try{
      await _db.collection("Users").doc(uid).update({'bio': bio});
    }catch (e){
      debugPrint(e.toString());
    }
  }

  //* DELETE USER İNFO
  Future<void> deleteUserInfoFromFirebase(String uid) async{
    WriteBatch batch = _db.batch();


    //* delete user doc
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);

    //* DELETE USER POSTS
    QuerySnapshot userPosts = 
      await _db.collection("Posts").where('uid', isEqualTo: uid).get();

    for (var post in userPosts.docs){
      batch.delete(post.reference);
    }

    //* DELETE USER COMMENTS
    QuerySnapshot userComments = 
      await _db.collection("Comments").where('uid', isEqualTo: uid).get();
    
    for (var comment in userComments.docs){
      batch.delete(comment.reference);
    }

    //* delete likes done by this user 
    QuerySnapshot allPosts = await _db.collection("Posts").get();
    for (QueryDocumentSnapshot post in allPosts.docs){
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>? ?? [];

      if (likedBy.contains(uid)){
        batch.update(post.reference,{
          'likedBy': FieldValue.arrayRemove([uid]),
          'likes': FieldValue.increment(-1),
        });
      }
    }

    //* UPDATE FOLLOWER & FOLLOWİNG RECORDS ACCORDİNGLY.. (LATER)


    //* COMMİT BATCH
    await batch.commit();

  }


  //! POST MESSAGE


  //* post message

  Future<void> postMessageInFirebase(String message) async{
    try{
      //* get current uid
      String uid = _auth.currentUser!.uid;

      //* use this uid to get the user's profile
      UserProfile? user = await getUserFromFirebase(uid);

      Post newPost = Post(
        id: '',    //* firebase otomatik olarak yapıcak
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
        );

        Map<String, dynamic>newPostMap = newPost.toMap();

        await _db.collection("Posts").add(newPostMap);
    }catch (e){
      debugPrint(e.toString());
    }
  }

  //? delete a post
  Future<void> deletePostFromFirebase(String postId) async{
    try{
      await _db.collection("Posts").doc(postId).delete();
    }catch(e){
      debugPrint(e.toString());
    }
  } 


  //! get all posts

  Future<List<Post>> getAllPostsFromFirebase()async{
    try{
      QuerySnapshot snapshot = await _db
      //* postların olduğu collectiona git
      .collection("Posts")
      //* kronolojik sırası
      .orderBy('timestamp',descending: true)
      //* dataları getir 
      .get();
      
      //* listeliyor postları 
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    }catch(e){
      return [];
    }
  }

  //* get individual posts


 
  //? like atma durumu

  Future<void> toggleLikeInFirebase(String postId)async{
    try{
      //* get current id
      String uid = _auth.currentUser!.uid;
      //* go to doc for this post 
      DocumentReference postDoc = _db.collection("Posts").doc(postId);
      //* execute like 
      await _db.runTransaction(
        (transaction) async{
        
        //* get post data 
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);
        
        //? get like of users who like this post
        List<String> likedBy =
          List<String>.from(postSnapshot['likedBy'] ?? []);

        //! get like count
        int currentLikeCount = postSnapshot['likes'];

        //* if user has not liked this post yet => then like
        if(!likedBy.contains(uid)){
          //* add user to like list 
          likedBy.add(uid);

          //* increment like count
          currentLikeCount++;

          //* if user has already liked this post => then unlike
        }else{
          //* remove user from like list 
          likedBy.remove(uid);

          //* decreament like count
          currentLikeCount--; 
        }

        //* update in firebase 

        transaction.update(postDoc,{
          'likes':currentLikeCount,
          'likedBy':likedBy,
          }
        );
      },
    );
  }catch(e){
    debugPrint(e.toString());
  }
}

  //* COMMENT the

  //* add comment to a post
  Future<void> addCommentInFirebase(String postId,message) async{
    try{
      //* get current user
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);


      //* create a new comment 
      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: uid,
        name: user!.name,
        username:user.username,
        message: message,
        timestamp: Timestamp.now(),
      );


      //* convert comment to map 
      Map<String, dynamic> newCommentMap = newComment.toMap();


      //* to store in firebase
      await _db.collection("Comments").add(newCommentMap);
    }catch(e){
      debugPrint(e.toString());
    }
  }


  //*Delete a comment from a post
  Future<void> deleteCommentInFirebase(String commentId) async{
    try{
      await _db.collection("Comments").doc(commentId).delete();
    }catch(e){
      debugPrint(e.toString());
    }
  }


  //* fetch a comment for a post
  Future<List<Comment>> getCommentsFromFirebase(String postId) async{
    try{
      //* get all comments for a post
      QuerySnapshot snapshot = await _db
     .collection("Comments")
     .where("postId", isEqualTo: postId)
     .get();
      
      //* listeliyor comments
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    }catch(e){
      debugPrint(e.toString());
      return [];
    }
  }

  //! account stuff yani report ya da blocklama durumu 

  //* report a post
  Future<void> reportUserInFirebase(String postId, userId) async{
  
  //* get current user id 
  final currentUserId = _auth.currentUser!.uid;

  //* create a report
  final report = {
    'reportedBy': currentUserId,
    'messageId': postId,
    'messageOwnerId': userId,
    'timestamp': Timestamp.now(),
    };

    //* update in firestore
    await _db.collection("Reports").add(report);
  }

    //* BLOCK USER
    Future<void> blockUserInFirebase(String userId) async{
      //* get current user id
      final currentUserId = _auth.currentUser!.uid;
      
      //* add this user to blocked list
      await _db.
      collection("Users").
      doc(currentUserId).
      collection("BlockedUsers").
      doc(userId).
      set({});
  }

  //* Unblock user
  Future<void> unblockUserInFirebase(String blockedUserId) async{
    //* get current user id
    final currentUserId = _auth.currentUser!.uid;

    //! unblock in firebase
          await _db.
      collection("Users").
      doc(currentUserId).
      collection("BlockedUsers").
      doc(blockedUserId).
      delete();
  }

  //* get list of blocked users
  Future<List<String>> getBlockedUidsFromFirebase() async{
    //* get current user id
    final currentUserId = _auth.currentUser!.uid;


    //* get data of blocked users
    final snapshot = await _db.
    collection("Users").
    doc(currentUserId).
    collection("BlockedUsers").
    get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }




  //? TAKİP ETME 
  //* follow user
  Future<void> followUserInFirebase(String uid) async{
    
    //* get current logged in user
    final currentUserId = _auth.currentUser!.uid;


    //* add target user to the current user's following 
    await _db.
    collection("Users").
    doc(currentUserId).
    collection("Following").
    doc(uid).
    set({});

    //* add current user to the target user's followers
    await _db.
    collection("Users").
    doc(uid).
    collection("Followers").
    doc(currentUserId).
    set({});
  }


  //* unfollow user
  Future<void> unfollowUserInFirebase(String uid) async{
    
    //* get current logged in user
    final currentUserId = _auth.currentUser!.uid;


    //* remove target user from the current user's following
    await _db.
    collection("Users").
    doc(currentUserId).
    collection("Following").
    doc(uid).
    delete();

    //* remove current user from target user's followers
    await _db.
    collection("Users").
    doc(uid).
    collection("Followers").
    doc(currentUserId).
    delete();
  }


  //* Get a user's followers: list of uids
  Future<List<String>> getFollowerUidsFromFirebase(String uid) async{
    
    //* get the followers from firebase
    final snapshot = await _db.
    collection("Users").
    doc(uid).
    collection("Followers").
    get();

    //* return as a nice simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

    //* Get a user's following: list of uids
  Future<List<String>> getFollowingUidsFromFirebase(String uid) async{
    
    //* get the following from firebase
    final snapshot = await _db.
    collection("Users").
    doc(uid).
    collection("Following").
    get();
 
    //* return as a nice simple list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  //* arama kısmı kişileri aradığımız kısım 
  //* search for users by name

  Future<List<UserProfile>> searchUserInFirebase(String searchTerm)async{
    try{
      QuerySnapshot snapshot = await _db
        .collection("Users")
        .where('username',isGreaterThanOrEqualTo: searchTerm)
        .where('username',isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();

      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    }
    catch(e){
      debugPrint(e.toString());
      return [];  
    }
  }
}   