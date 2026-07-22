import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.username);
    final bioController = TextEditingController(text: user.bio);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Edit Profile', style: AppTheme.headlineMd.copyWith(color: AppColors.secondary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: AppTheme.bodyMd,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: AppColors.outline),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.zinc800)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: AppTheme.bodyMd,
              decoration: const InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: AppColors.outline),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.zinc800)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx);
          }, child: const Text('Cancel', style: TextStyle(color: AppColors.zinc500))),
          ElevatedButton(
            onPressed: () async {
              await ApiService.put('/users/me', {
                'username': nameController.text,
                'bio': bioController.text,
              });
              if (context.mounted && Navigator.canPop(ctx)) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: authService.userProfileStream,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return Column(children: [
              _buildTopBar(context),
              Expanded(child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                _buildHeroSection(),
                _buildIdentity(user),
                _buildXpProgress(user),
                const SizedBox(height: 24),
                _buildStatsGrid(user),
                const SizedBox(height: 32),
                _buildBadges(),
                const SizedBox(height: 32),
                if (user != null) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showEditProfileDialog(context, user),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('EDIT PROFILE', style: AppTheme.labelCaps.copyWith(color: AppColors.secondary)),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
              ]))),
            ]);
          }
        )
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) => Container(
    height: 64, padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.zinc800))),
    child: Row(children: [
      const Icon(Icons.terminal, color: AppColors.secondary, size: 24),
      const SizedBox(width: 8),
      Text('DEV_DUEL', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: AppColors.secondary, letterSpacing: -0.5)),
      const Spacer(),
      IconButton(
        onPressed: () async {
          await AuthService().signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
      ),
      GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings Coming Soon')),
          );
        },
        child: const Icon(Icons.settings_outlined, color: AppColors.zinc500, size: 24),
      ),
    ]),
  );

  Widget _buildHeroSection() => Container(
    height: 200, width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [AppColors.surfaceContainerHigh, AppColors.surface, AppColors.background]),
    ),
  );

  Widget _buildIdentity(UserModel? user) => Column(children: [
    // Avatar with gold ring
    Transform.translate(
      offset: const Offset(0, -64),
      child: Column(
        children: [
          Container(
            width: 128, height: 128,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft,
                colors: [AppColors.secondary, AppColors.primaryContainer, AppColors.secondary]),
              boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.2), blurRadius: 20)],
            ),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 4), color: AppColors.surfaceContainerLowest),
              child: const Icon(Icons.person, color: AppColors.secondary, size: 56),
            ),
          ),
          // Elite badge
          Transform.translate(offset: const Offset(32, -20), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black, width: 2)),
            child: Text(user?.level != null && user!.level > 10 ? 'ELITE' : 'NOVICE', style: AppTheme.labelCaps.copyWith(fontSize: 10, color: AppColors.onPrimaryContainer)),
          )),
          const SizedBox(height: 4),
          Text(user?.username ?? 'BinaryKing', style: AppTheme.headlineMd),
          const SizedBox(height: 4),
          Text(user?.email ?? 'Stanford University', style: AppTheme.bodyMd.copyWith(color: AppColors.outline)),
        ],
      ),
    ),
  ]);

  Widget _buildXpProgress(UserModel? user) {
    int currentXp = user?.xp ?? 0;
    int nextLevelXp = (user?.level ?? 1) * 1000;
    double progress = currentXp / nextLevelXp;

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('LEVEL ${user?.level ?? 1}', style: AppTheme.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
        Text('$currentXp / $nextLevelXp XP', style: AppTheme.labelCaps.copyWith(color: AppColors.secondary)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(999), child: Container(height: 8, color: AppColors.surfaceContainerHigh, child: FractionallySizedBox(
        alignment: Alignment.centerLeft, widthFactor: progress.clamp(0.01, 1.0),
        child: Container(decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 10)])),
      ))),
    ]));
  }

  Widget _buildStatsGrid(UserModel? user) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: GridView.count(
    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.4,
    children: [
      _statCard(Icons.sports_martial_arts, '${user?.battles ?? 0}', 'Battles'),
      _statCard(Icons.emoji_events, '${user?.wins ?? 0}', 'Wins'),
      _statCard(Icons.terminal, '${user?.problems ?? 0}', 'Problems'),
      _statCard(Icons.local_fire_department, '${user?.streak ?? 0}', 'Streak'),
    ],
  ));

  Widget _statCard(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.outlineVariant)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Icon(icon, color: AppColors.secondary, size: 20),
      Text(value, style: AppTheme.headlineMd.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
      Text(label, style: AppTheme.labelCaps.copyWith(fontSize: 10, color: AppColors.outline)),
    ]),
  );

  Widget _buildBadges() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('RECENT BADGES', style: AppTheme.labelCaps.copyWith(color: AppColors.onSurfaceVariant))),
    const SizedBox(height: 16),
    SizedBox(height: 120, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), children: [
      _badgeCard(Icons.bolt, 'Swift Coder', AppColors.primaryContainer),
      const SizedBox(width: 12),
      _badgeCard(Icons.pest_control, 'Bug Hunter', AppColors.secondary),
      const SizedBox(width: 12),
      _badgeCard(Icons.psychology, 'Problem Solver', const Color(0xFFFAE448)),
    ])),
  ]);

  Widget _badgeCard(IconData icon, String label, Color color) => Container(
    width: 128, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.outlineVariant)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceContainerLowest, border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Icon(icon, color: color, size: 24)),
      const SizedBox(height: 12),
      Text(label, textAlign: TextAlign.center, style: AppTheme.labelCaps.copyWith(fontSize: 10)),
    ]),
  );


}
