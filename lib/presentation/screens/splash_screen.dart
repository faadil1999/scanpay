import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'auth/auth_choice_screen.dart';
import 'auth/register_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _animationDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceIn),
    );

    _controller.forward();

    _startInitSequence();
  }

  Future<void> _startInitSequence() async {
    // 1. Wait for minimum splash animation time (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _animationDone = true;
    });

    // 2. Check current auth state
    final authState = ref.read(authStateProvider);

    if (!authState.isLoading) {
      // If already resolved (data or error), navigate immediately
      _navigateToNext(authState.valueOrNull);
    } else {
      // 3. If still loading, set a safety timeout (5 more seconds)
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_navigated) {
          debugPrint("Auth check timed out, redirecting to AuthChoice");
          _navigateToNext(null);
        }
      });
    }
  }

  void _navigateToNext(dynamic user) async {
    if (_navigated || !mounted) return;
    _navigated = true;

    if (user != null) {
      // Fetch user data from Firestore
      try {
        // Set a timeout for fetching user data to avoid hanging
        await ref.read(authControllerProvider).fetchUserData().timeout(
          const Duration(seconds: 5),
          onTimeout: () => debugPrint("Fetch user data timed out"),
        );
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthChoiceScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes reactively
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (previous, next) {
      if (_animationDone && !next.isLoading) {
        _navigateToNext(next.valueOrNull);
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF006847), // Vert Bénin
              Color(0xFF004D35),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Points décoratifs en arrière-plan (simulés)
            Opacity(
              opacity: 0.1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                ),
                itemCount: 100,
                itemBuilder: (context, index) => Center(
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            // Contenu central
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Box
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFCC00), // Jaune MTN
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 50,
                          color: Color(0xFF006847),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Name
                      const Text(
                        'ScanPay',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),

                      // Benin Label
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(height: 2, width: 30, color: const Color(0xFFFFCC00)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'BÉNIN',
                              style: TextStyle(
                                color: Color(0xFFFFCC00),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(height: 2, width: 30, color: const Color(0xFFFFCC00)),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Loading Indicator
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer text
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Scanner. Payer. C\'est tout.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
