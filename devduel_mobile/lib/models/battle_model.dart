enum BattleStatus { searching, active, completed }

class BattleModel {
  final String id;
  final String player1Id;
  final String player2Id;
  final String problemId;
  final BattleStatus status;
  final String? winnerId;
  final DateTime createdAt;

  BattleModel({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.problemId,
    this.status = BattleStatus.searching,
    this.winnerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'player1Id': player1Id,
      'player2Id': player2Id,
      'problemId': problemId,
      'status': status.toString().split('.').last,
      'winnerId': winnerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BattleModel.fromMap(Map<String, dynamic> map, String docId) {
    return BattleModel(
      id: docId,
      player1Id: map['player1Id'] ?? '',
      player2Id: map['player2Id'] ?? '',
      problemId: map['problemId'] ?? '',
      status: BattleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'searching'),
        orElse: () => BattleStatus.searching,
      ),
      winnerId: map['winnerId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
