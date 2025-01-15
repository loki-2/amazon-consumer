import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
    bool isBuyerAccount,
  ) async {
    try {
      // Try to sign in
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists in Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'isBuyerAccount': isBuyerAccount,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Store user type in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_${userCredential.user!.uid}_isBuyerAccount', isBuyerAccount);
      await prefs.setBool('isBuyerAccount', isBuyerAccount);
      await prefs.setBool('isLoggedIn', true);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required bool isBuyerAccount,
  }) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'isBuyerAccount': isBuyerAccount,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Store user type in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_${userCredential.user!.uid}_isBuyerAccount', isBuyerAccount);
      await prefs.setBool('isBuyerAccount', isBuyerAccount);
      await prefs.setBool('isLoggedIn', true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle(bool isBuyerAccount) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create or update user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'isBuyerAccount': isBuyerAccount,
        'lastSignIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Store user type in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_${userCredential.user!.uid}_isBuyerAccount', isBuyerAccount);
      await prefs.setBool('isBuyerAccount', isBuyerAccount);
      await prefs.setBool('isLoggedIn', true);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if user is a buyer
  Future<bool> isBuyerAccount() async {
    final user = currentUser;
    if (user == null) return false;
    
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['isBuyerAccount'] ?? true;
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account exists with this email. Please sign up first.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'invalid-email':
        return 'Email address is invalid.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'user-disabled':
        return 'User has been disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}