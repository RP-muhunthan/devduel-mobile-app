import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0;
  final _tabs = ['Global', 'Weekly', 'Friends'];
  final _databaseService = DatabaseService();
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(child: StreamBuilder<List<UserModel>>(
        stream: _databaseService.leaderboardStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }

          final users = snapshot.data ?? [];

          return Column(children: [
            _buildTopBar(),
            Expanded(child: Stack(children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(24,24,24,0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Leaderboard', style: AppTheme.headlineLg.copyWith(color: AppColors.primaryContainer)),
                    const SizedBox(height: 20),
                    _buildTabs(),
                  ])),
                  const SizedBox(height: 24),
                  if (users.length >= 3) _buildPodium(users.sublist(0, 3)),
                  const SizedBox(height: 24),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(
                    children: users.asMap().entries.map((entry) {
                      if (entry.key < 3) return const SizedBox.shrink(); // Skip podium users in the list
                      return Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildRow(entry.value, entry.key + 1));
                    }).toList(),
                  )),
                ])),
              Positioned(bottom: 0, left: 0, right: 0, child: _buildYourRank(users)),
            ])),
          ]);
        }
      )),
    );
  }

  Widget _buildTopBar() => Container(
    height: 64, padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.cardBorder))),
    child: Row(children: [
      const Icon(Icons.terminal, color: AppColors.primaryContainer, size: 24),
      const SizedBox(width: 8),
      Text('DEV_DUEL', style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryContainer, letterSpacing: 2)),
      const Spacer(),
      Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainer, border: Border.all(color: AppColors.cardBorder)),
        child: const Icon(Icons.person, color: AppColors.zinc500, size: 18)),
    ]),
  );

  Widget _buildTabs() => SizedBox(height: 40, child: ListView.separated(
    scrollDirection: Axis.horizontal, itemCount: _tabs.length,
    separatorBuilder: (context, index) => const SizedBox(width: 12),
    itemBuilder: (ctx, i) {
      final sel = i == _selectedTab;
      return GestureDetector(onTap: () => setState(() => _selectedTab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: sel ? null : Border.all(color: AppColors.cardBorder)),
          child: Text(_tabs[i], style: AppTheme.labelCaps.copyWith(
            color: sel ? Colors.black : AppColors.zinc500)),
        ));
    },
  ));

  Widget _buildPodium(List<UserModel> top3) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        _buildPodiumItem(top3[1].username, '${top3[1].xp} XP', 80, AppColors.silver, Icons.workspace_premium, false),
        const SizedBox(width: 16),
        // 1st place
        _buildPodiumItem(top3[0].username, '${top3[0].xp} XP', 112, AppColors.primaryContainer, Icons.emoji_events, true),
        const SizedBox(width: 16),
        // 3rd place
        _buildPodiumItem(top3[2].username, '${top3[2].xp} XP', 80, AppColors.bronze, Icons.workspace_premium, false),
      ],
    ));
  }

  Widget _buildPodiumItem(String name, String xp, double size, Color borderColor, IconData icon, bool isFirst) {
    return Column(children: [
      Icon(icon, color: borderColor, size: isFirst ? 32 : 24),
      const SizedBox(height: 8),
      Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: isFirst ? 4 : 2),
          color: AppColors.surfaceContainer,
          boxShadow: isFirst ? [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.15), blurRadius: 20)] : null,
        ),
        child: Icon(Icons.person, color: borderColor, size: isFirst ? 48 : 32),
      ),
      const SizedBox(height: 12),
      SizedBox(width: isFirst ? 128 : 96, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: isFirst ? AppTheme.headlineMd.copyWith(fontSize: 18, color: AppColors.primaryContainer) : AppTheme.labelCaps.copyWith(color: AppColors.onSurface))),
      const SizedBox(height: 2),
      Text(xp, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: isFirst ? AppColors.primaryContainer : AppColors.zinc500)),
    ]);
  }

  Widget _buildRow(UserModel user, int rank) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
    child: Row(children: [
      SizedBox(width: 24, child: Text(rank.toString().padLeft(2, '0'), style: GoogleFonts.jetBrainsMono(color: AppColors.zinc500))),
      const SizedBox(width: 16),
      Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainer),
        child: const Icon(Icons.person, color: AppColors.zinc500, size: 22)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(user.username, style: AppTheme.labelCaps),
        Text('LEVEL ${user.level} • ${user.rank}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.zinc500)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${user.xp}', style: GoogleFonts.jetBrainsMono(fontSize: 14, color: AppColors.primaryContainer)),
        Text('XP', style: TextStyle(fontSize: 8, color: AppColors.zinc500)),
      ]),
    ]),
  );

  Widget _buildYourRank(List<UserModel> users) {
    final myUid = _auth.currentUser?.uid;
    final myIndex = users.indexWhere((u) => u.uid == myUid);
    if (myIndex == -1) return const SizedBox.shrink();
    
    final me = users[myIndex];

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Text((myIndex + 1).toString(), style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
        const SizedBox(width: 16),
        Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.2), border: Border.all(color: Colors.black.withValues(alpha: 0.1))),
          child: const Icon(Icons.person, color: Colors.black54, size: 22)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('YOU (${me.username.toUpperCase()})', style: AppTheme.labelCaps.copyWith(color: Colors.black)),
          Text('GLOBAL RANKING', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.black54)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${me.xp}', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          Text('XP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
        ]),
      ]),
    );
  }
}
