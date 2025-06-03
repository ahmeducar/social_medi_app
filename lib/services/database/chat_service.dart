import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone_app/models/message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mesaj gönderme
  Future<void> sendMessage(String recipientUid, String message) async {
    String senderUid = _auth.currentUser!.uid;

    // Sohbet odası ID'si oluşturuluyor (senderId, receiverId'ye göre)
    String conversationId = _getConversationId(senderUid, recipientUid);

    // Mesaj verisini oluşturma
    Message newMessage = Message(
      id: '', // Firestore otomatik olarak ID oluşturacak
      conversationId: conversationId,
      senderId: senderUid,
      receiverId: recipientUid,
      message: message,
      timestamp: Timestamp.now(),

      read: false,
    );
  
    // Mesajı Firestore'a ekleyin
    await _db.collection('Conversations')
        .doc(conversationId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Sohbet odası ID'sini oluşturma (senderId ve receiverId'ye göre)
  String _getConversationId(String senderUid, String receiverUid) {
    if (senderUid.hashCode <= receiverUid.hashCode) {
      return '$senderUid-$receiverUid';
    } else {
      return '$receiverUid-$senderUid';
    }
  }

  // Mesajları alma
  Stream<List<Message>> getMessages(String recipientUid) {
    String senderUid = _auth.currentUser!.uid;
    String conversationId = _getConversationId(senderUid, recipientUid);

    return _db.collection('Conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromDocument(doc)).toList();
    });
  }
}
