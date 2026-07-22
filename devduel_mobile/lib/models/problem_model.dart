enum Difficulty { easy, medium, hard }

class TestCase {
  final String input;
  final String expectedOutput;

  TestCase({required this.input, required this.expectedOutput});

  Map<String, dynamic> toMap() => {'input': input, 'expectedOutput': expectedOutput};
  factory TestCase.fromMap(Map<String, dynamic> map) => TestCase(
    input: map['input'] ?? '',
    expectedOutput: map['expectedOutput'] ?? '',
  );
}

class ProblemModel {
  final String id;
  final String title;
  final String description;
  final Difficulty difficulty;
  final Map<String, String> starterCodes; 
  final List<TestCase> testCases;
  final int points;

  ProblemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.starterCodes,
    required this.testCases,
    this.points = 100,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty.toString().split('.').last,
      'starterCodes': starterCodes,
      'testCases': testCases.map((t) => t.toMap()).toList(),
      'points': points,
    };
  }

  static int _parseInt(dynamic value, int defaultValue) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory ProblemModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawStarterCodes = map['starterCodes'];
    final Map<String, String> starterCodes = (rawStarterCodes is Map)
        ? Map<String, String>.from(rawStarterCodes)
        : {'dart': '// No starter code available'};

    final rawTestCases = map['testCases'] as List?;
    final List<TestCase> testCases = (rawTestCases != null)
        ? rawTestCases.map((t) => TestCase.fromMap(t as Map<String, dynamic>)).toList()
        : [TestCase(input: 'Default', expectedOutput: 'Passed')];

    return ProblemModel(
      id: docId,
      title: map['title'] ?? 'Untitled Problem',
      description: map['description'] ?? 'No description available',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == (map['difficulty'] ?? 'easy'),
        orElse: () => Difficulty.easy,
      ),
      starterCodes: starterCodes,
      testCases: testCases,
      points: _parseInt(map['points'], 100),
    );
  }
}
