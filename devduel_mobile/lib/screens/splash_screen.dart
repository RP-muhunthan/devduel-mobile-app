import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;

  int _countdown = 2;
  late Timer _timer;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);


    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (mounted) {
          setState(() {
            if (_countdown > 0) {
              _countdown--;
            } else {
              _timer.cancel();
            }
          });
          if (_countdown == 0) {
            final loggedIn = await _authService.isLoggedIn();
            if (mounted) {
              if (loggedIn) {
                Navigator.of(context).pushReplacementNamed('/home');
              } else {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Stack(
            children: [
              // Top Status Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SYSTEM.KERNEL.LOAD: OK',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    Text(
                      'NETWORK.STATUS: CONNECTED',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Crossed Swords Logo (Simulated)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                blurRadius: 50,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Swords
                        Transform.rotate(
                          angle: -0.5,
                          child: const Icon(
                            Icons.colorize, // Closest to a blade shape in standard icons
                            size: 64,
                            color: AppColors.secondary,
                          ),
                        ),
                        Transform.rotate(
                          angle: 0.5,
                          child: const Icon(
                            Icons.colorize,
                            size: 64,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Brand name
                    Text(
                      'DEVDUEL',
                      style: GoogleFonts.roboto(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      'CODE.  BATTLE.  CONQUER.',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3 Loading dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF424242),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Bottom Section
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    // Terminal circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        color: Colors.black,
                      ),
                      child: const Icon(
                        Icons.terminal,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'INITIALIZING HACKER ENVIRONMENT...',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: (10 - _countdown) / 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          minHeight: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
