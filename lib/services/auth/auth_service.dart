import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone_app/services/database/database_service.dart';  

class AuthService {
  final _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;


  Future<UserCredential> loginEmailPassword(String email, password)async{
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    }on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> registerEmailPassword(String email, String password)async{

    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;    
    }on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }


  //* delete account
  Future<void> deleteAccount() async {

    //* get current uid
    User? user = getCurrentUser();

    if(user != null){

      //* delete user's data from firestore
      await DatabaseService().deleteCommentInFirebase(user.uid);


      //* delete the user's auth record
      await user.delete();

    }
  }
}