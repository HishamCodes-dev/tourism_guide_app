import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _initCurrentUser();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null || _auth.currentUser != null;

  void _initCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = UserModel.fromFirebaseUser(firebaseUser);
      // Fetch details from Firestore if present
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          _currentUser = UserModel.fromMap(doc.data()!);
        }
      } catch (_) {}
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Send Password Reset Email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(_mapFirebaseAuthException(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage("Failed to send reset email. Please try again.");
      _setLoading(false);
      return false;
    }
  }

  /// Registration / Sign Up Logic with Firebase Auth & Firestore
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name.trim());
        await user.reload();

        final updatedUser = _auth.currentUser ?? user;
        _currentUser = UserModel(
          uid: updatedUser.uid,
          email: updatedUser.email ?? email,
          name: name.trim(),
        );

        // Save User Document into Firestore
        try {
          await _firestore.collection('users').doc(user.uid).set(
            _currentUser!.toMap(),
            SetOptions(merge: true),
          );
        } catch (_) {}

        _setLoading(false);
        return true;
      }

      _setErrorMessage("Failed to register user. Please try again.");
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(_mapFirebaseAuthException(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage("An unexpected error occurred. Please try again.");
      _setLoading(false);
      return false;
    }
  }

  /// Login Logic with Firebase Auth
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        _currentUser = UserModel.fromFirebaseUser(user);
        
        // Fetch extra fields from Firestore if available
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            _currentUser = UserModel.fromMap(doc.data()!);
          }
        } catch (_) {}

        _setLoading(false);
        return true;
      }

      _setErrorMessage("Authentication failed. User not found.");
      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(_mapFirebaseAuthException(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setErrorMessage("An unexpected error occurred. Please try again.");
      _setLoading(false);
      return false;
    }
  }

  /// Logout Logic
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Map Firebase Auth exception codes to human-readable error messages
  String _mapFirebaseAuthException(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid login credentials. Please check your email and password.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
