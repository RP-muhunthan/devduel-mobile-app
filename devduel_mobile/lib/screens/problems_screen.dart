import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/database_service.dart';
import 'main_scaffold.dart';

class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({super.key});

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLanguage = 'Python 3.10';
  final _languages = ['Python 3.10', 'Dart', 'Java', 'C++'];
  late Timer _timer;
  int _timeRemaining = 12 * 60 + 43;
  bool _isRunning = false;
  bool _isSubmitting = false;

  String get _formattedTime {
    final m = _timeRemaining ~/ 60;
    final s = _timeRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  final String _starterCode = '''class Solution:
    def findMedianSortedArrays(s
        # TODO: Implement O(log
    merged = sorted(nums1 + nums2)
    n = len(merged)
    if n % 2 == 0:
        return (merged[n //
    else:
        return float(merged[''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.secondary, size: 64),
              const SizedBox(height: 16),
              Text(
                'VICTORY!',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You solved the challenge before your opponent. +50 XP',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.zinc400,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    MainScaffold.setTab(context, 0); // go home
                  },
                  child: Text('RETURN TO LOBBY', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildPlayerProgress(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProblemSection(),
                    _buildExampleSection(),
                    _buildCodeEditorSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.zinc800)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
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
                'Median of Two Sorted Arrays',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const Spacer(),
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
                _formattedTime,
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

  // ── Player progress ────────────────────────────────────────────────────────
  Widget _buildPlayerProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.zinc800)),
      ),
      child: Column(
        children: [
          _buildPlayerRow(
            avatarLetter: 'R',
            name: 'Rahul Kumar',
            passed: 2,
            total: 3,
            progress: 2 / 3,
            avatarColor: AppColors.secondary,
          ),
          const SizedBox(height: 10),
          _buildPlayerRow(
            avatarLetter: 'Y',
            name: 'You (Pro)',
            passed: 1,
            total: 3,
            progress: 1 / 3,
            avatarColor: AppColors.zinc500,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required String avatarLetter,
    required String name,
    required int passed,
    required int total,
    required double progress,
    required Color avatarColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarColor.withValues(alpha: 0.15),
            border: Border.all(color: avatarColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: avatarColor,
              ),
            ),
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
                  Text(
                    name,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '$passed/$total Pass',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.zinc400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppColors.zinc800,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Problem section ────────────────────────────────────────────────────────
  Widget _buildProblemSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HARD badge + ID
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.hardBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'HARD',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.hard,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ID: #40201',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: AppColors.zinc500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Problem statement heading
          Text(
            'Problem Statement',
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Problem description
          RichText(
            text: TextSpan(
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppColors.zinc400,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'Given two sorted arrays '),
                TextSpan(
                  text: 'nums1',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: AppColors.secondary),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'nums2',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: AppColors.secondary),
                ),
                const TextSpan(
                    text:
                        ' of size m and n respectively, return the '),
                TextSpan(
                  text: 'median',
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
                const TextSpan(text: ' of the two sorted arrays.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: AppColors.zinc400,
                height: 1.6,
              ),
              children: [
                const TextSpan(
                    text:
                        'The overall run time complexity should be '),
                TextSpan(
                  text: 'O(log (m+n))',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 13, color: AppColors.secondary),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Example section ────────────────────────────────────────────────────────
  Widget _buildExampleSection() {
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
          Text(
            'EXAMPLE 1',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.zinc500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12, color: AppColors.zinc400, height: 1.7),
              children: [
                const TextSpan(text: 'Input: nums1 = [1,3], nums2 = [2]\n'),
                const TextSpan(text: 'Output: 2.00000\n'),
                TextSpan(
                  text: 'Explanation: merged array =\n[1,2,3] and median is 2.',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.zinc500,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Code editor section ────────────────────────────────────────────────────
  Widget _buildCodeEditorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // Tabs + Language selector
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.zinc800),
              bottom: BorderSide(color: AppColors.zinc800),
            ),
          ),
          child: Row(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.primaryContainer,
                indicatorWeight: 2,
                labelColor: AppColors.primaryContainer,
                unselectedLabelColor: AppColors.zinc500,
                labelStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
                tabs: const [
                  Tab(text: 'CODE'),
                  Tab(text: 'TEST\nCASES'),
                ],
              ),
              const Spacer(),
              // Language dropdown
              PopupMenuButton<String>(
                color: AppColors.surfaceContainer,
                onSelected: (String result) {
                  setState(() {
                    _selectedLanguage = result;
                  });
                },
                itemBuilder: (BuildContext context) => _languages.map((String lang) => PopupMenuItem<String>(
                  value: lang,
                  child: Text(lang, style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface, fontSize: 11)),
                )).toList(),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.zinc700),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedLanguage,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppColors.onSurface,
                        ),
                      ),
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

        // Code editor body
        Container(
          height: 260,
          color: AppColors.surfaceContainerLowest,
          child: TabBarView(
            controller: _tabController,
            children: [
              // CODE tab
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Container(
                      width: 36,
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: List.generate(
                          _starterCode.split('\n').length,
                          (i) => Container(
                            height: 22,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AppColors.zinc700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Code
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildCodeLines(),
                      ),
                    ),
                  ],
                ),
              ),
              // TEST CASES tab
              Center(
                child: Text(
                  'No test cases yet.',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: AppColors.zinc500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCodeLines() {
    final lines = _starterCode.split('\n');
    final highlightLine = 6; // merged = sorted line gets yellow highlight
    return List.generate(lines.length, (i) {
      final isHighlighted = i == highlightLine - 1;
      return Container(
        height: 22,
        color: isHighlighted
            ? AppColors.primaryContainer.withValues(alpha: 0.12)
            : Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          lines[i],
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: _getLineColor(lines[i], i),
            height: 1,
          ),
        ),
      );
    });
  }

  Color _getLineColor(String line, int index) {
    if (line.trimLeft().startsWith('class ') ||
        line.trimLeft().startsWith('def ')) {
      return const Color(0xFF569CD6); // blue for keywords
    }
    if (line.trimLeft().startsWith('#')) {
      return AppColors.zinc500; // grey for comments
    }
    if (line.trimLeft().startsWith('return')) {
      return const Color(0xFFC586C0); // purple for return
    }
    return AppColors.onSurface;
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.zinc800)),
      ),
      child: Row(
        children: [
          // CONSOLE
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
                    const Icon(Icons.terminal,
                        color: AppColors.zinc400, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'CONSOLE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zinc400,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // RUN CODE
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () async {
                if (_isRunning) return;
                setState(() => _isRunning = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  setState(() => _isRunning = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Code executed successfully! 3/3 Test cases passed.', style: GoogleFonts.jetBrainsMono()),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                  _tabController.animateTo(1);
                }
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimaryContainer,
                          ),
                        )
                      : Text(
                          'RUN CODE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onPrimaryContainer,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // SUBMIT
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                if (_isSubmitting) return;
                setState(() => _isSubmitting = true);
                // Award 50 XP
                await DatabaseService().updateUserXP(50);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  setState(() => _isSubmitting = false);
                  _showVictoryDialog();
                }
              },
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onSurface,
                          ),
                        )
                      : Text(
                          'SUBMIT',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
