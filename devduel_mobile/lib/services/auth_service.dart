import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // ── Current user (in-memory cache) ───────────────────────────────────────
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // ── Stream of user profile changes ─────────────────────────────────────────
  Stream<UserModel?> get userProfileStream async* {
    yield _currentUser;
    try {
      yield await loadCurrentUser();
    } catch (_) {}
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      try {
        yield await loadCurrentUser();
      } catch (_) {}
    }
  }

  // ── Auth State ────────────────────────────────────────────────────────────

  /// Returns true if a JWT token exists in storage.
  Future<bool> isLoggedIn() => ApiService.hasToken();

  /// Loads the current user profile from the API using the stored JWT.
  Future<UserModel?> loadCurrentUser() async {
    try {
      final data = await ApiService.get('/users/me');
      _currentUser = UserModel.fromMap(data, data['uid']);
      return _currentUser;
    } catch (e) {
      debugPrint('[AuthService] Failed to load user: $e');
      return null;
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<UserModel> signIn(String email, String password) async {
    final data = await ApiService.post(
      '/auth/login',
      {'email': email.trim(), 'password': password},
      auth: false,
    );

    await ApiService.saveToken(data['access_token']);
    _currentUser = UserModel.fromMap(data['user'], data['user']['uid']);
    return _currentUser!;
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<UserModel> signUp(String email, String password, {String? username}) async {
    // Use part before @ as default username
    final resolvedUsername = username ?? email.split('@')[0];

    final data = await ApiService.post(
      '/auth/register',
      {
        'email': email.trim(),
        'password': password,
        'username': resolvedUsername,
      },
      auth: false,
    );

    await ApiService.saveToken(data['access_token']);
    _currentUser = UserModel.fromMap(data['user'], data['user']['uid']);
    return _currentUser!;
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _currentUser = null;
    await ApiService.clearToken();
  }
}
