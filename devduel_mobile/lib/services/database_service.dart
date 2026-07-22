import 'dart:async';
import 'package:flutter/material.dart';
import '../models/problem_model.dart';
import '../models/battle_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class DatabaseService {
  final AuthService _auth = AuthService();

  // ── Problems ──────────────────────────────────────────────────────────────

  /// Fetch all problems from the REST API.
  Future<List<ProblemModel>> getProblems() async {
    try {
      final data = await ApiService.get('/problems') as List<dynamic>;
      return data
          .map((p) => ProblemModel.fromMap(Map<String, dynamic>.from(p), p['id']))
          .toList();
    } catch (e) {
      debugPrint('[DB] getProblems error: $e');
      return [];
    }
  }

  /// Fetch a single problem by its ID from the REST API.
  Future<ProblemModel?> getProblem(String id) async {
    try {
      final data = await ApiService.get('/problems/$id');
      if (data == null) return null;
      return ProblemModel.fromMap(Map<String, dynamic>.from(data), data['id']);
    } catch (e) {
      debugPrint('[DB] getProblem error: $e');
      return null;
    }
  }

  /// Stream wrapper around getProblems() — polls every 30 seconds.
  Stream<List<ProblemModel>> get problemsStream {
    return Stream.periodic(const Duration(seconds: 30), (_) => null)
        .startWith(null)
        .asyncMap((_) => getProblems());
  }

  // ── Matchmaking Queue ─────────────────────────────────────────────────────

  Future<void> joinQueue() async {
    try {
      await ApiService.post('/battles/queue/join', {});
    } catch (e) {
      debugPrint('[DB] joinQueue error: $e');
    }
  }

  Future<void> leaveQueue() async {
    try {
      await ApiService.delete('/battles/queue/leave');
    } catch (e) {
      debugPrint('[DB] leaveQueue error: $e');
    }
  }

  Future<Map<String, dynamic>?> tryToMatch() async {
    try {
      final result = await ApiService.post('/battles/queue/match', {});
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('[DB] tryToMatch error: $e');
      return null;
    }
  }

  /// Polls the active battle every 3 seconds.
  Stream<BattleModel?> findMatch() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return Stream.periodic(const Duration(seconds: 3), (_) => null)
        .startWith(null)
        .asyncMap((_) => _getActiveBattle());
  }

  Future<BattleModel?> _getActiveBattle() async {
    try {
      final data = await ApiService.get('/battles/active');
      if (data == null) return null;
      return BattleModel.fromMap(Map<String, dynamic>.from(data), data['id']);
    } catch (e) {
      debugPrint('[DB] _getActiveBattle error: $e');
      return null;
    }
  }

  // ── Simulated Battle ──────────────────────────────────────────────────────

  Future<void> createSimulatedBattle() async {
    try {
      await ApiService.post('/battles/simulate', {});
      debugPrint('[DB] Simulated battle created.');
    } catch (e) {
      debugPrint('[DB] createSimulatedBattle error: $e');
    }
  }

  // ── Complete Battle ────────────────────────────────────────────────────────

  Future<void> completeBattle(String battleId, String winnerId) async {
    try {
      await ApiService.put('/battles/$battleId/complete', {'winner_id': winnerId});
    } catch (e) {
      debugPrint('[DB] completeBattle error: $e');
    }
  }

  // ── Leaderboard ────────────────────────────────────────────────────────────

  Future<List<UserModel>> getLeaderboard() async {
    try {
      final data = await ApiService.get('/users/leaderboard') as List<dynamic>;
      return data
          .map((u) => UserModel.fromMap(Map<String, dynamic>.from(u), u['uid']))
          .toList();
    } catch (e) {
      debugPrint('[DB] getLeaderboard error: $e');
      return [];
    }
  }

  /// Stream wrapper around getLeaderboard() — polls every 15 seconds.
  Stream<List<UserModel>> get leaderboardStream {
    return Stream.periodic(const Duration(seconds: 15), (_) => null)
        .startWith(null)
        .asyncMap((_) => getLeaderboard());
  }

  // ── User XP ────────────────────────────────────────────────────────────────

  Future<void> updateUserXP(int points) async {
    try {
      await ApiService.put('/users/me/xp', {'points': points});
    } catch (e) {
      debugPrint('[DB] updateUserXP error: $e');
    }
  }

  // ── Seed Problems (call once on first run) ─────────────────────────────────

  Future<void> seedInitialProblems() async {
    try {
      await ApiService.post('/problems/seed', {});
    } catch (e) {
      debugPrint('[DB] seedInitialProblems error: $e');
    }
  }
}

// Extension to add startWith to Stream
extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
