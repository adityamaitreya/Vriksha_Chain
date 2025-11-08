import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  String get userRole {
    if (_user?.email == null) return 'user';
    if (_user!.email!.endsWith('@vrikshachain.com')) return 'admin';
    return 'user';
  }

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _authService.signInWithEmailAndPassword(email, password);
      return credential != null;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      return credential != null;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}


