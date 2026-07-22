class UserModel {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final int xp;
  final int level;
  final String rank;
  final int wins;
  final int battles;
  final int problems;
  final int streak;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.bio = 'Adventurous Coder 🚀',
    this.xp = 0,
    this.level = 1,
    this.rank = 'Newbie',
    this.wins = 0,
    this.battles = 0,
    this.problems = 0,
    this.streak = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'xp': xp,
      'level': level,
      'rank': rank,
      'wins': wins,
      'battles': battles,
      'problems': problems,
      'streak': streak,
    };
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      username: map['username'] ?? 'New Coder',
      bio: map['bio'] ?? 'Adventurous Coder 🚀',
      xp: _parseInt(map['xp'], 0),
      level: _parseInt(map['level'], 1),
      rank: map['rank'] ?? 'Newbie',
      wins: _parseInt(map['wins'], 0),
      battles: _parseInt(map['battles'], 0),
      problems: _parseInt(map['problems'], 0),
      streak: _parseInt(map['streak'], 0),
    );
  }
}
