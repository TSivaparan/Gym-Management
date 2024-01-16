import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getCurrentUserUid() async {
    final User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return documentSnapshot.data() as Map<String, dynamic>?;
  }
}
