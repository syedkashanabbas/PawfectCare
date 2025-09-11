import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login User + fetch role
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return null;

      
      final doc = await _db.collection("users").doc(user.uid).get();

      if (!doc.exists) {
        throw Exception("User profile not found in Firestore");
      }

      final data = doc.data()!;
      return {"user": user, "role": data["role"] ?? "Unknown"};
    } catch (e) {
      throw Exception(e.toString());
    }
  }


  Future<User?> registerUser(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return null;

    
      await _db.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "role": role,
        "createdAt": DateTime.now(),
      });

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }


  Future<void> logoutUser() async {
    await _auth.signOut();
  }


  User? get currentUser => _auth.currentUser;
}
