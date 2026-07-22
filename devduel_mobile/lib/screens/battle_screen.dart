import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/database_service.dart';
import '../models/battle_model.dart';
import '../models/problem_model.dart';
import 'dart:async';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  int _selectedDifficulty = 1; // 0=Easy,1=Medium,2=Hard,3=Random
  int _selectedTopic = 0; // 0=All,1=Arrays,...
  bool _isSearching = false;
  final _databaseService = DatabaseService();
  Timer? _searchTimer;

  final _difficulties = ['Easy', 'Medium', 'Hard', 'Random'];
  final _topics = ['All', 'Arrays', 'Trees', 'DP', 'Graphs', 'Strings'];

  final _codeController = TextEditingController();

  @override
  void dispose() {
    _searchTimer?.cancel();
    _codeController.dispose();
    _databaseService.leaveQueue();
    super.dispose();
  }

  void _startSearch() async {
    setState(() => _isSearching = true);
    await _databaseService.joinQueue();

    // Try to match every 2 seconds
    _searchTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await _databaseService.tryToMatch();
      
      // Simulate opponent if waiting too long (for demo purposes)
      if (timer.tick > 3) {
        _simulateMatch();
        timer.cancel();
      }
    });
  }

  void _simulateMatch() async {
    await _databaseService.createSimulatedBattle();
  }

  BattleModel? _debugBattle;
  final String _selectedLanguage = 'dart';
  String _testResult = '';
  bool _isRunningTests = false;
  int _activeTab = 0; // 0=CODE, 1=TEST CASES
  bool _showLangDropdown = false;

  Widget _buildTestConsole(ProblemModel problem) {
    if (_testResult.isEmpty) return const SizedBox.shrink();
    
    final isSuccess = _testResult.contains('PASSED');
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSuccess ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(isSuccess ? 'TEST CASES PASSED' : 'TEST CASES FAILED', 
                style: AppTheme.labelCaps.copyWith(color: isSuccess ? Colors.green : Colors.red, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_testResult, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.zinc400)),
        ],
      ),
    );
  }

  void _runTests(ProblemModel problem) async {
    setState(() {
      _isRunningTests = true;
      _testResult = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRunningTests = false;
      _testResult = 'Test Case 1: Input: ${problem.testCases[0].input} => Output: ${problem.testCases[0].expectedOutput} (PASSED)\nTest Case 2: Input: ${problem.testCases[1].input} => Output: ${problem.testCases[1].expectedOutput} (PASSED)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: StreamBuilder<BattleModel?>(
          stream: _databaseService.findMatch(),
          builder: (context, snapshot) {
            final battle = _debugBattle ?? snapshot.data;

            // Only enter the arena if we have a match AND we were actually looking for one
            if (battle != null && (_isSearching || _debugBattle != null)) {
              return _buildBattleArena(battle);
            }

            if (_isSearching) {
              return _buildSearchingUI();
            }

            return _buildSelectionUI();
          }
        ),
      ),
    );
  }

  Widget _buildSearchingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 80, height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            color: AppColors.secondary,
            backgroundColor: AppColors.zinc800,
          ),
        ),
        const SizedBox(height: 40),
        Text('SEARCHING FOR OPPONENT', style: AppTheme.labelCaps.copyWith(fontSize: 16, letterSpacing: 4)),
        const SizedBox(height: 16),
        Text('Connecting to global arena...', style: AppTheme.bodyMd.copyWith(color: AppColors.zinc500)),
        const SizedBox(height: 64),
        OutlinedButton(
          onPressed: () {
            _searchTimer?.cancel();
            _databaseService.leaveQueue();
            setState(() => _isSearching = false);
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text('CANCEL SEARCH', style: AppTheme.labelCaps.copyWith(color: AppColors.error)),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            _searchTimer?.cancel();
            setState(() {
              _debugBattle = BattleModel(
                id: 'debug',
                player1Id: 'YOU',
                player2Id: 'BOT',
                problemId: '1',
                status: BattleStatus.active,
                createdAt: DateTime.now(),
              );
            });
          },
          child: Text('DEBUG: FORCE ENTER ARENA', style: AppTheme.bodyMd.copyWith(color: AppColors.secondary.withValues(alpha: 0.5))),
        ),
      ],
    );
  }

  Widget _buildBattleArena(BattleModel battle) {
    return FutureBuilder<ProblemModel?>(
      future: DatabaseService().getProblem(battle.problemId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }

        final problem = snapshot.data;
        if (problem == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('PROBLEM DATA NOT FOUND', style: AppTheme.labelCaps.copyWith(color: AppColors.error)),
                const SizedBox(height: 8),
                Text('Try clicking "REPAIR" on Home Screen.', style: AppTheme.bodyMd.copyWith(color: AppColors.zinc500)),
              ],
            ),
          );
        }

        if (_codeController.text.isEmpty) {
          _codeController.text = problem.starterCodes[_selectedLanguage] ?? '';
        }

        return Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────
            _buildArenaTopBar(battle, problem),
            // ── Player progress ───────────────────────────────────────
            _buildArenaPlayerProgress(),
            // ── Scrollable content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildArenaProblemSection(problem),
                    _buildArenaExampleSection(problem),
                    _buildArenaCodeEditor(problem),
                    if (_testResult.isNotEmpty) _buildTestConsole(problem),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // ── Bottom bar ────────────────────────────────────────────
            _buildArenaBottomBar(problem),
          ],
        );
      },
    );
  }

  Widget _buildArenaTopBar(BattleModel battle, ProblemModel problem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.zinc800)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _debugBattle = null);
            },
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHALLENGE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.zinc500,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  problem.title,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TIME REMAINING',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.zinc500,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '05:00',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.notifications_none_rounded,
              color: AppColors.zinc500, size: 22),
        ],
      ),
    );
  }

  Widget _buildArenaPlayerProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.zinc800)),
      ),
      child: Column(
        children: [
          _buildArenaPlayerRow(
            letter: 'R', name: 'Opponent',
            passed: 2, total: 3, progress: 2 / 3,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          _buildArenaPlayerRow(
            letter: 'Y', name: 'You (Pro)',
            passed: 1, total: 3, progress: 1 / 3,
            color: AppColors.zinc500,
          ),
        ],
      ),
    );
  }

  Widget _buildArenaPlayerRow({
    required String letter, required String name,
    required int passed, required int total,
    required double progress, required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(letter,
              style: GoogleFonts.roboto(
                fontSize: 13, fontWeight: FontWeight.w900, color: color)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name,
                    style: GoogleFonts.roboto(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
                  Text('$passed/$total Pass',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: AppColors.zinc400)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress, minHeight: 5,
                  backgroundColor: AppColors.zinc800,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArenaProblemSection(ProblemModel problem) {
    final diffStr = problem.difficulty.toString().split('.').last;
    final diff = diffStr[0].toUpperCase() + diffStr.substring(1);
    Color dc, db;
    if (diff == 'Easy') { dc = AppColors.easy; db = AppColors.easyBg; }
    else if (diff == 'Hard') { dc = AppColors.hard; db = AppColors.hardBg; }
    else { dc = AppColors.medium; db = AppColors.mediumBg; }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: db, borderRadius: BorderRadius.circular(4)),
                child: Text(diff.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: dc, letterSpacing: 1)),
              ),
              const SizedBox(width: 10),
              Text('ID: #${problem.id}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10, color: AppColors.zinc500)),
            ],
          ),
          const SizedBox(height: 14),
          Text('Problem Statement',
            style: GoogleFonts.roboto(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.onSurface)),
          const SizedBox(height: 10),
          Text(problem.description,
            style: GoogleFonts.roboto(
              fontSize: 13, color: AppColors.zinc400, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildArenaExampleSection(ProblemModel problem) {
    if (problem.testCases.isEmpty) return const SizedBox.shrink();
    final tc = problem.testCases.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.zinc800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXAMPLE 1',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10, fontWeight: FontWeight.w800,
              color: AppColors.zinc500, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text('Input: ${tc.input}\nOutput: ${tc.expectedOutput}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12, color: AppColors.zinc400, height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildArenaCodeEditor(ProblemModel problem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Tabs + language
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.zinc800),
              bottom: BorderSide(color: AppColors.zinc800),
            ),
          ),
          child: Row(
            children: [
              _buildArenaTab('CODE', 0),
              _buildArenaTab('TEST CASES', 1),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showLangDropdown = !_showLangDropdown),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.zinc700),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedLanguage.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10, color: AppColors.onSurface)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.zinc500, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Code body
        Container(
          height: 260,
          color: AppColors.surfaceContainerLowest,
          child: _activeTab == 0
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line numbers
                      SizedBox(
                        width: 36,
                        child: Column(
                          children: List.generate(
                            (_codeController.text.split('\n').length).clamp(1, 99),
                            (i) => Container(
                              height: 22,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 8),
                              child: Text('${i + 1}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12, color: AppColors.zinc700)),
                            ),
                          ),
                        ),
                      ),
                      // Editable code
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12, color: AppColors.onSurface),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '// Write your code here',
                            hintStyle: GoogleFonts.jetBrainsMono(
                              fontSize: 12, color: AppColors.zinc700),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text('Run tests to see results.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: AppColors.zinc500)),
                ),
        ),
      ],
    );
  }

  Widget _buildArenaTab(String label, int index) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryContainer : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primaryContainer : AppColors.zinc500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildArenaBottomBar(ProblemModel problem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.zinc800)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.zinc700),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.terminal, color: AppColors.zinc400, size: 16),
                    const SizedBox(width: 6),
                    Text('CONSOLE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.zinc400, letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _isRunningTests ? null : () => _runTests(problem),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isRunningTests
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimaryContainer))
                      : Text('RUN CODE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11, fontWeight: FontWeight.w800,
                            color: AppColors.onPrimaryContainer, letterSpacing: 1)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (_testResult.contains('PASSED')) _showResultsDialog(problem);
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('SUBMIT',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: AppColors.onSurface, letterSpacing: 1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultsDialog(ProblemModel problem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.zinc950,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.secondary, size: 80),
            const SizedBox(height: 24),
            Text('VICTORY!', style: AppTheme.headlineLg.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text('Problem Solved Perfectly', style: AppTheme.bodyMd.copyWith(color: AppColors.zinc400)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.zinc900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text('${problem.points} XP', style: AppTheme.headlineMd.copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Award XP
                await DatabaseService().updateUserXP(problem.points);
                
                if (context.mounted && Navigator.canPop(context)) {
                  Navigator.of(context).pop(); // Safe Pop
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text('RETURN TO BASE', style: AppTheme.labelCaps.copyWith(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // Legacy header removed — replaced by _buildArenaTopBar

  Widget _buildSelectionUI() {
    return Column(
      children: [
        // Top app bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.zinc800, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
                    onPressed: () {
                      // Safety: Don't pop if we are in a tab. Just hide searching if needed.
                      if (_isSearching) {
                        setState(() => _isSearching = false);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DEVDUEL',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppColors.secondary,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.notifications_outlined,
                  color: AppColors.secondary, size: 24),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title
                Text('Choose Battle Mode', style: AppTheme.headlineLg),
                const SizedBox(height: 8),
                Text(
                  'Select your arena and prove your technical superiority.',
                  style: AppTheme.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                // 1v1 Battle card
                _buildBattleModeCard(
                  icon: Icons.person_outline,
                  iconBg: AppColors.secondaryContainer,
                  iconColor: const Color(0xFF392700),
                  title: '1v1 Battle',
                  titleColor: AppColors.secondary,
                  description:
                      'Face one opponent, same problem, fastest wins. High intensity, pure skill.',
                  buttonText: 'START',
                  isFilled: true,
                  onTap: _startSearch,
                ),
                const SizedBox(height: 16),

                // 3v3 Team Battle card
                _buildBattleModeCard(
                  icon: Icons.groups_outlined,
                  iconBg: AppColors.primaryContainer,
                  iconColor: AppColors.onPrimaryContainer,
                  title: '3v3 Team Battle',
                  titleColor: AppColors.primaryFixedDim,
                  description:
                      'Team of 3 vs 3, collaborate and conquer. Coordinate strategy to solve complex algorithms.',
                  buttonText: 'COMING SOON',
                  isFilled: false,
                  hasGlow: true,
                  onTap: () {},
                ),
                const SizedBox(height: 32),

                // Difficulty selector
                Text(
                  'DIFFICULTY',
                  style: AppTheme.labelCaps
                      .copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_difficulties.length, (i) {
                    final isSelected = i == _selectedDifficulty;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedDifficulty = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          _difficulties[i],
                          style: AppTheme.labelCaps.copyWith(
                            color: isSelected
                                ? AppColors.onSecondary
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Topic selector
                Text(
                  'TOPIC SELECTOR',
                  style: AppTheme.labelCaps
                      .copyWith(color: AppColors.outline),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_topics.length, (i) {
                    final isSelected = i == _selectedTopic;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedTopic = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          _topics[i],
                          style: AppTheme.labelCaps.copyWith(
                            color: isSelected
                                ? AppColors.onSecondary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBattleModeCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String description,
    required String buttonText,
    required bool isFilled,
    required VoidCallback onTap,
    bool hasGlow = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryFixedDim.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.headlineMd.copyWith(color: titleColor),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTheme.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isFilled
                ? ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: AppTheme.labelCaps.copyWith(
                        color: AppColors.onSecondary,
                        letterSpacing: 3,
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: AppTheme.labelCaps.copyWith(
                        color: AppColors.secondary,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
