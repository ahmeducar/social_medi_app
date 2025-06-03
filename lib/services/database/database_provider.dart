import 'package:flutter/foundation.dart';
import 'package:twitter_clone_app/models/comment.dart';
import 'package:twitter_clone_app/models/message.dart';
import 'package:twitter_clone_app/models/post.dart';
import 'package:twitter_clone_app/models/user.dart';
import 'package:twitter_clone_app/services/auth/auth_service.dart';
import 'package:twitter_clone_app/services/database/chat_service.dart';
import 'package:twitter_clone_app/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {

  //? SERVICES
  final _db = DatabaseService();
  final _auth = AuthService();
  
  //*CHAT İLE ALAKALI KODLAR
  final ChatService _chatService = ChatService();

  //* Mesaj gönderme
  Future<void> sendMessage(String recipientUid, String message) async {
    await _chatService.sendMessage(recipientUid, message);
    notifyListeners(); // UI'yi bilgilendir
  }
 
  //* Mesajları almak
  Stream<List<Message>> getMessages(String recipientUid) {
    return _chatService.getMessages(recipientUid);
  }
  //* CHAT İLE ALAKALI KODLAR BURAYA KADARDI

  //* USER PROFILE
  //! GET USER PROFILE GIVEN UID
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  //? update userBio
  Future<void> updateBio(String bio) => _db.updateUserBioInfoFirebase(bio);

  //* local list of 
  
  
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];


  //* get posts
  List<Post> get allPosts => _allPosts; // 'allPost' yerine 'allPosts' olarak değiştirin
  List<Post> get followingPosts => _followingPosts;



  //* post message 
  Future<void> postMessage(String message) async {
    await _db.postMessageInFirebase(message);
    //* RELOAD DATA FROM FIREBASE
    await loadAllPosts();
  }

  //* fetch all posts 
  Future<void> loadAllPosts() async { 
    //* get all posts from firebase
    final allPosts = await _db.getAllPostsFromFirebase();
    
    //* get blocked user ids
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //* filter out blocked users posts 
    _allPosts = 
      allPosts.where((post) =>!blockedUserIds.contains(post.uid)).toList();

    //* filter out the following posts
    loadFollowingPosts();


    //! initialize local like data
    initializeLikeMap();

    notifyListeners();
  }

  //* filter and return post given uid
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }


  //* load following posts -> posts from users that current user follows
  Future<void> loadFollowingPosts()async{
    
    //* get current uid
    String currentUid = _auth.getCurrentUid();

    //* get list of uids that the current logged in user follows (from firebase)
    final followingUserIds = await _db.getFollowingUidsFromFirebase(currentUid);


    //* filter all posts to be the ones for the following tab
    _followingPosts = 
      _allPosts.where((post) => followingUserIds.contains(post.uid)).toList();


    //* update UI
    notifyListeners();
  }
   

  //* delete post  
  Future<void> deletePost(String postId) async {
    //* delete from firebase
    await _db.deletePostFromFirebase(postId);
    //* reload from firebase
    await loadAllPosts();
  }

  //* Local map to track like counts for each 
  var _likeCounts = <String, int>{}; // 'final' yerine 'var' kullanıldı

  //* local list to track posts liked by current user
  var _likedPosts = <String>[]; // 'final' yerine 'var' kullanıldı

  //* does current user like this post ? 
  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  //* get like count of a post 
  int getLikeCount(String postId) => _likeCounts[postId] ?? 0; // null kontrolü yapıldı

  //* initialize like map locally 
  void initializeLikeMap() {
    //* get current user id
    final currentUserID = _auth.getCurrentUid();

    //* clear liked posts(for when new user signs in, clear local data)
    _likedPosts.clear();
    

    //* for each post get like data
    for (var post in _allPosts) {
      //* update like count map
      _likeCounts[post.id] = post.likeCount;

      //* if the current user already liked this post
      if (post.likedBy.contains(currentUserID)) {
        //* add post id to liked posts
        _likedPosts.add(post.id);
      }
    }
  }

  //* toggle like
  Future<void> toggleLike(String postId) async {
  // Kopya alıyoruz ve doğru türde kopyalar oluşturuyoruz.
  List<String> likedPostsOriginal = List.from(_likedPosts);  // Kopya almak için List<String> kullanıyoruz
  Map<String, int> likeCountsOriginal = Map.from(_likeCounts); // Kopya almak için Map<String, int> kullanıyoruz

  //? perform like / unlike 
  if (_likedPosts.contains(postId)) {
    //* remove from liked posts
    _likedPosts.remove(postId);

    //* decrease like count
    _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
  } else {
    //* add to liked posts
    _likedPosts.add(postId);

    //* increase like count
    _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
  }

  notifyListeners();

  try {
    await _db.toggleLikeInFirebase(postId);
  } catch (e) {
    // Hata durumunda kopyaları geri yüklüyoruz
    _likedPosts = likedPostsOriginal;
    _likeCounts = likeCountsOriginal;
  }
}

  //* COMMENT (

  //* local list of comments 
  final Map<String, List<Comment>> _comments = {};


  //* get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];


  //? fetch comments from database for a post
  Future<void> loadComments(String postId) async {

    //* get comments for this post
    final allComments = await _db.getCommentsFromFirebase(postId);


    //! update local data
    _comments[postId] = allComments;


    //* update UI
    notifyListeners();
  }


  //* add a comment 
  Future<void> addComment(String postId, message) async {
    
    //* add comment in firebase
    await _db.addCommentInFirebase(postId, message);

    //*reload comments
    await loadComments(postId);
  }


  //* delete a comment
  Future<void> deleteComment(String commentId, postId) async {
    
    
    //* delete comment in firebase
    await _db.deleteCommentInFirebase(commentId);


    //* reload comments
    await loadComments(postId);
  }

  //* ACCOUNT STUFFF

  //* local list of blocked users 
  List<UserProfile> _blockedUsers = [];


  //* get list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  
  //* fetch blocked users
  Future<void> loadBlockedUsers() async {
    
    //* get list of blocked users
    final blockedUserIds = await _db.getBlockedUidsFromFirebase();

    //*get full user details using uid
    final blockedUsersData = await Future.wait(
      blockedUserIds.map((id) => _db.getUserFromFirebase(id)));

    //* return as a list
    _blockedUsers = blockedUsersData.whereType<UserProfile>().toList();

    //* update UI
    notifyListeners();
  }
//* block user
  Future<void> blockUser(String userId) async {
    
    //* perform block in firebase
    await _db.blockUserInFirebase(userId);

    //* reload blocked users
    await loadBlockedUsers();

    //*reload data 
    await loadAllPosts();

    //* update UI
    notifyListeners();
  }

  //* unblock user
  Future<void> unblockUser(String blockedUserId) async {
    
    //* perform unblock in firebase
    await _db.unblockUserInFirebase(blockedUserId);

    //* reload blocked users
    await loadBlockedUsers();

    //* reload posts 
    await loadAllPosts();


    //* update UI
    notifyListeners();
  }


 
  //* report user & post


  Future<void> reportUser(String postId,userId) async {
    
    //* perform report in firebase
    await _db.reportUserInFirebase(postId,userId);
  }


    //* FOLLOW

  //* everything here is done with uids (String)

  //*--------------------------------------------------

  //* each user id has a list of :
  //* - followers uid
  //* - following uid



  //*  'uid1': [ list of uids there are followers / following],
  //*  'uid2': [ list of uids there are followers / following],
  //*  'uid3': [ list of uids there are followers / following],
  //*  'uid4': [ list of uids there are followers / following],

  
  //* local map
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, int> _followerCount = {};
  final Map<String, int> _followingCount = {};


  //* get counts for followers & following locally: given a uid
  int getFollowerCount(String uid) => _followerCount[uid] ?? 0 ;
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0 ;


  //* load followers
  Future<void> loadUserFollowers(String uid)async{

    //* get the list of follower uids from firebase
    final listOfFollowerUids = await _db.getFollowerUidsFromFirebase(uid);

    //*update local data
    _followers[uid] = listOfFollowerUids;
    _followerCount[uid] = listOfFollowerUids.length;

    //* update UI
    notifyListeners();
  }

    //* load following
    Future<void> loadUserFollowing(String uid)async{

    //* get the list of following uids from firebase
    final listOfFollowingUids = await _db.getFollowingUidsFromFirebase(uid);

    //*update local data
    _following[uid] = listOfFollowingUids;
    _followingCount[uid] = listOfFollowingUids.length;

    //* update UI
    notifyListeners();
  }

    //* follow user
    Future<void> followUser(String targetUserId)async{
      /*

    currently logged in user wants to follow target user



      */

    //* get current uid 
    final currentUserId = _auth.getCurrentUid();

    //* initialize with empty lists if null
    _following.putIfAbsent(currentUserId, () => []);
    _followers.putIfAbsent(targetUserId, () => []);

    //* optimistic UI changes update the local data & revert back if database request fails


    //* follow if current user is not one of the target user's followers
    if(!_followers[targetUserId]!.contains(currentUserId)){

      //* add current user to target user's follower list
      _followers[targetUserId]?.add(currentUserId);

      //* update follower count
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) +1;


      //* then add target user to current user following
      _following[currentUserId]?.add(targetUserId);

      //* update following count  
      _followingCount[currentUserId] = 
        (_followingCount[currentUserId]?? 0) +1;

    }
    //* update UI
    notifyListeners();

    //* UI has been optimistically updated above with local data 

    //* now let's try to make this request to our database

    try{
      
      //* follow user in firebase
      await _db.followUserInFirebase(targetUserId);

      //* reload current user's followers
      await loadUserFollowers(currentUserId);


      //* reload current user's following
      await loadUserFollowing(currentUserId);
    }

    catch(e){
      //* remove current user from target user's followers
      _followers[targetUserId]?.remove(currentUserId);

      //* update follower count 
      _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) -1;

      //* remove from current user's following 
      _following[currentUserId]?.remove(targetUserId);

      //* update following count
       _followingCount[currentUserId] = (_followingCount[currentUserId] ?? 0) -1;


      //* update UI
      notifyListeners();
    }
  }


    //* unfollow user 
    Future<void> unfollowUser(String targetUserId) async{
      /*
      currently logged in user wants to unfollow target user
      
      */
      //* get current uid 
      final currentUserId = _auth.getCurrentUid();

      //* initialize lists if they dont exist
      _following.putIfAbsent(currentUserId,() => []);
      _followers.putIfAbsent(targetUserId, () => []);
      /*
      
      Optimistic UI changes: Update the local data first & revert back if the database
      request fails 

      */

      //* unfollow if current user is one of the target user's following 
      if(_followers[targetUserId]!.contains(currentUserId)){

        //* remove current user from target user's following
        _followers[targetUserId]?.remove(currentUserId);

        //* update follower count
        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 1)-1 ;

        //* remove target user from current user's following list
        _following[currentUserId]?.remove(targetUserId);

        //* update following count
        _followingCount[currentUserId] = (_followingCount[currentUserId]?? 1)-1 ;
      }

      //* update UI
      notifyListeners();

      /*  
      UI has been optimistically updated with local data above.
      Now lets try to make this request to our database.
      */

      try{
        //* unfollow target user in firebase 
        await _db.unfollowUserInFirebase(targetUserId);

        //* reload user followers
        await loadUserFollowers(currentUserId);


        //* reload user following
        await loadUserFollowing(currentUserId);
      }
      
      //* if there is an error .. revert back to original
      catch(e){

        //*add current user back into target user's followers
        _followers[targetUserId]?.add(currentUserId);

        
        //* update follower count
        _followerCount[targetUserId] = (_followerCount[targetUserId] ?? 0) +1;

        //* add target user back into current user's following list
        _following[currentUserId]?.add(currentUserId);

        //* update following count
        _followingCount[currentUserId] = (_followingCount[currentUserId] ?? 0) +1;

        //* update UI
        notifyListeners();
      }
    }
    
    
    //* is current user following target user ?
    bool isFollowing(String uid){
      final currentUserId = _auth.getCurrentUid();
      return _followers[uid]?.contains(currentUserId) ?? false;
    }
  

  
  //* MAP OF PROFİLES
  
  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};


  //* get list of follower profiles for a given user
  List<UserProfile> getListOfFollowersProfile(String uid) =>
    _followersProfile[uid] ?? [];

  //* get list of following profiles for a given user
  List<UserProfile> getListOfFollowingProfile(String uid) =>
    _followingProfile[uid] ?? [];
  


  //* load follower profiles for a given uid
Future<void> loadUserFollowerProfiles(String uid) async{
    try{

      //* get list of follower uids from firebase
      final followerIds = await _db.getFollowerUidsFromFirebase(uid);

      //* create list of user profiles  
      List<UserProfile> followerProfiles = [];

      //* go thru each follower id
      for (String followerId in followerIds){

        //* get user profile from firebase with this uid
        UserProfile? followerProfile = await _db.getUserFromFirebase(followerId);


        //* add to follower profile
        if(followerProfile != null){
          followerProfiles.add(followerProfile);
        }
      }

      //* update local data 
      _followersProfile[uid] = followerProfiles;

      //* update UI
      notifyListeners();
    }

    //* any errors
    catch(e){
      debugPrint(e.toString());
    }
  }

  //* load following profiles for a given uid
Future<void> loadUserFollowingProfiles(String uid) async{
    try{

      //* get list of following uids from firebase
      final followingIds = await _db.getFollowingUidsFromFirebase(uid);

      //* create list of user profiles  
      List<UserProfile> followingProfiles = [];

      //* go thru each following id
      for (String followingId in followingIds){

        //* get user profile from firebase with this uid
        UserProfile? followingProfile = await _db.getUserFromFirebase(followingId);


        //* add to following profile
        if(followingProfile != null){
          followingProfiles.add(followingProfile);
        }
      }

      //* update local data 
      _followingProfile[uid] = followingProfiles;

      //* update UI
      notifyListeners();
    }

    //* any errors
    catch(e){
      debugPrint(e.toString());
    }
  }


  //* SEARCH USERS


  //* list of search results
  List<UserProfile> _searchResults = [];


  //* get list of search results
  List<UserProfile> get searchResult => _searchResults;


  //* method to search for a user
  Future<void> searchUser (String searchTerm) async {
    try{
      //* search users in firebase
      final results = await _db.searchUserInFirebase(searchTerm);

      //* update local data 
      _searchResults = results;
      //* update UI
      notifyListeners();
    }

    catch(e){
      debugPrint(e.toString());
    }
  }
  
}
