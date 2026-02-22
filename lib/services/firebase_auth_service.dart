import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class FirebaseAuthService {
  // 🔹 Singleton instance of FirebaseAuth
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // =================== SIGN UP ===================
  /// Creates a new user with email & password
  /// Returns true if successful, false otherwise
  static Future<bool> signup({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log("Signup successful: $email", name: 'FirebaseAuthService');
      return true;
    } on FirebaseAuthException catch (e) {
      developer.log(
        "Signup Error: ${e.code} - ${e.message}",
        name: 'FirebaseAuthService',
      );
      return false;
    } catch (e) {
      developer.log("Signup Error: $e", name: 'FirebaseAuthService');
      return false;
    }
  }

  // =================== LOGIN ===================
  /// Signs in existing user with email & password
  /// Returns true if successful, false otherwise
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log("Login successful: $email", name: 'FirebaseAuthService');
      return true;
    } on FirebaseAuthException catch (e) {
      developer.log(
        "Login Error: ${e.code} - ${e.message}",
        name: 'FirebaseAuthService',
      );
      return false;
    } catch (e) {
      developer.log("Login Error: $e", name: 'FirebaseAuthService');
      return false;
    }
  }

  // =================== LOGOUT ===================
  /// Signs out the currently logged-in user
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      developer.log("User logged out successfully", name: 'FirebaseAuthService');
    } catch (e) {
      developer.log("Logout Error: $e", name: 'FirebaseAuthService');
    }
  }

  // =================== CURRENT USER ===================
  /// Returns currently logged-in Firebase user, or null
  static User? currentUser() {
    return _auth.currentUser;
  }

  // =================== IS LOGGED IN ===================
  /// Returns true if a user is logged in, false otherwise
  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}
