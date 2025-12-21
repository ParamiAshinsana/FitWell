import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore
  static FirebaseFirestore get firestore => _firestore;
  static CollectionReference get usersCollection => _firestore.collection('users');

  // Helper methods
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static bool get isAuthenticated => currentUser != null;
}

