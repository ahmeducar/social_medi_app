import 'package:cloud_firestore/cloud_firestore.dart';

//* postları zaman like id uid name ve mesaj gibi özelliklerle firebase de tutabilmek için oluşturduğumuz sayfa

class Post{
  final String id;
  final String uid;
  final String name;
  final String username;
  final String message;
  final Timestamp timestamp;
  final int likeCount;
  final List<String> likedBy;

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
  });

  //* firestore documentte bu şekilde gözükecek

  factory Post.fromDocument(DocumentSnapshot doc) {
   return Post(
      id: doc.id,
      uid: doc['uid'],
      name: doc['name'],
      username: doc['username'],
      message: doc['message'],
      timestamp: doc['timestamp'],
      likeCount: doc['likes'],
      likedBy: List<String>.from (doc['likedBy'] ?? []),
    );
  }

  //* map ile objectlere dönüştürüyoruz

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'username': username,
      'message': message,
      'timestamp': timestamp,
      'likes': likeCount,
      'likedBy': likedBy,   
    };  
  }
}