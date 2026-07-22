import 'package:flutter/material.dart';

import '../theme.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'main_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: StreamBuilder<UserModel?>(
          stream: authService.userProfileStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text('CONNECTION ERROR', style: AppTheme.labelCaps.copyWith(color: AppColors.error)),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red, fontSize: 10), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => DatabaseService().seedInitialProblems(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('REPAIR DATABASE'),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.secondary),
                    SizedBox(height: 24),
                    Text('CONNECTING TO ARENA...', style: TextStyle(color: AppColors.secondary, letterSpacing: 2)),
                  ],
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
               return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, color: AppColors.zinc500, size: 48),
                    SizedBox(height: 16),
                    Text('USER PROFILE NOT FOUND', style: TextStyle(color: AppColors.zinc500)),
                  ],
                ),
              );
            }
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: _buildTopBar(context, user),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Bento Grid Layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildXPRankCard(user)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildStreakCard(user)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDailyChallengeCard(context),
                        const SizedBox(height: 16),
                        _buildQuickBattleCard(context),
                        const SizedBox(height: 16),
                        _buildRecentActivitySection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, UserModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.zinc800),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDKcB3BNMLZe7tiDc8JIZfFsW_00ZElvSkmAGp-4tDhHaHZ5sll41udEOMWmxLKEbrjC9ohJ2hpOnTemDrNHrFyiZoySf4tM7V_Nvb_-3gZhpOO-E_2NkbkIac4gVEWfrJjqH0C2XqdhXvLzl6ppfmhYcAbBv4PDzfeRIXVk6GVLfbCzljcvjfx-M5RlTAfDTNbWaFfEFFFVvzyd0-Vpn4Vfz28dzV4tPjC6kUKzw-Wr2RY5evokYNw1YMEBUsfsCplYXt-B6PrKXn4'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, ${user?.username ?? "Coder"} 👋',
                      style: AppTheme.headlineMd.copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.email ?? 'Loading...',
                      style: AppTheme.labelCaps.copyWith(color: AppColors.zinc500, fontSize: 8),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.build_circle_outlined, color: AppColors.secondary, size: 24),
              tooltip: 'Repair Database',
              onPressed: () async {
                await DatabaseService().seedInitialProblems();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database Repaired! Try Battle again.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            IconButton(
              onPressed: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error, size: 24),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.zinc900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_none, color: AppColors.zinc500, size: 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildXPRankCard(UserModel? user) {
    int currentXp = user?.xp ?? 0;
    int nextLevelXp = (user?.level ?? 1) * 1000;
    double progress = currentXp / nextLevelXp;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.zinc950,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LEVEL ${user?.level ?? 1}', style: AppTheme.labelCaps.copyWith(color: AppColors.zinc500, fontSize: 10)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(user?.level != null && user!.level > 10 ? 'ELITE' : 'NOVICE', style: AppTheme.labelCaps.copyWith(color: AppColors.onSecondary, fontSize: 10)),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$currentXp', style: AppTheme.headlineMd.copyWith(color: AppColors.secondary)),
              Text(' / $nextLevelXp XP', style: AppTheme.labelCaps.copyWith(color: AppColors.zinc500)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.zinc800,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.zinc950,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${user?.streak ?? 0} Day Streak!', style: AppTheme.headlineMd.copyWith(fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(user?.streak != null && user!.streak > 0 ? 'You\'re on fire!' : 'Start your streak!', style: AppTheme.bodyMd.copyWith(color: AppColors.zinc500)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              bool active = (user?.streak ?? 0) > index;
              return Column(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? AppColors.secondary : AppColors.zinc800,
                      boxShadow: active ? [
                        const BoxShadow(color: AppColors.secondary, blurRadius: 4),
                      ] : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(['M','T','W','T','F','S','S'][index], style: AppTheme.labelCaps.copyWith(fontSize: 8, color: AppColors.zinc500)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.zinc950,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc800),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.zinc900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.zinc800),
                ),
                child: const Icon(Icons.terminal, color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.zinc800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('MEDIUM', style: AppTheme.labelCaps.copyWith(fontSize: 8, color: AppColors.zinc400)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.schedule, size: 12, color: AppColors.zinc500),
                        const SizedBox(width: 4),
                        Text('14:22:05', style: AppTheme.labelCaps.copyWith(fontSize: 10, color: AppColors.zinc500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Matrix Diagonal Sum', style: AppTheme.headlineMd.copyWith(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: AppColors.secondary, width: 4)),
            ),
            child: Text(
              'Given a square matrix mat, return the sum of the matrix diagonals...',
              style: AppTheme.codeBlock.copyWith(fontSize: 12, color: AppColors.zinc400),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              MainScaffold.setTab(context, 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('SOLVE NOW', style: AppTheme.labelCaps),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBattleCard(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc800),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCL_7XvRUGVR9SOjcIIVnMEvpoQCl6GfCyPrXjEYuBlKkdTNBAdI_6dulfvHMRN0zrnNtLYQQcM56u6PSUV1yTp7xPpk25TtARh8O-hCUa3SYEE6bA0sl5VwluOKNI8yZEKdVEvSRyupz1hwce3hqXD33MDLM0fKoNM-g5L_93DmtDcgzUHb96_UgvUZJe6AckALyiJIC9uLURVW3UObWwc7GAneSvXz6pn2XdaqYykuRSEceLsX81uQGSnOp1cu9sIasOvFmXX71OF'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Ready for a Duel?', style: AppTheme.headlineLg.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Match with a random opponent and race to solve problems.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMd.copyWith(color: AppColors.zinc400),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                MainScaffold.setTab(context, 1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 10,
                shadowColor: AppColors.errorContainer.withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, size: 20),
                  const SizedBox(width: 12),
                  Text('FIND BATTLE', style: AppTheme.labelCaps),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECENT ACTIVITY', style: AppTheme.labelCaps.copyWith(color: AppColors.zinc500)),
            TextButton(
              onPressed: () {},
              child: Text('VIEW ALL', style: AppTheme.labelCaps.copyWith(color: AppColors.secondary, fontSize: 10)),
            ),
          ],
        ),
        _buildActivityItem('AlexCode92', '2h ago', 'WIN', '+45 XP', true),
        const SizedBox(height: 12),
        _buildActivityItem('KevinDev', '5h ago', 'LOSE', '-12 XP', false),
      ],
    );
  }

  Widget _buildActivityItem(String name, String time, String result, String xp, bool isWin) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.zinc950,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.zinc800),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.zinc800,
                child: Icon(Icons.person, size: 20, color: AppColors.zinc500),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                  Text(time, style: AppTheme.bodyMd.copyWith(color: AppColors.zinc500, fontSize: 12)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                result,
                style: AppTheme.labelCaps.copyWith(
                  color: isWin ? AppColors.secondary : AppColors.error,
                  fontSize: 12,
                ),
              ),
              Text(xp, style: AppTheme.codeBlock.copyWith(fontSize: 12, color: AppColors.zinc400)),
            ],
          ),
        ],
      ),
    );
  }
}
