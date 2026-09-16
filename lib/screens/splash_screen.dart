import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'home_screen.dart';

/// Splash Screen adhering strictly to PRD Section 3.
/// Features a light warm preschool background, centered logo with subtle elastic entrance,
/// ample breathing room, short pause (~2.0s), and a smooth fade into Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _entryController.forward();

    // Short, deliberate pause (~2.1s) smoothly transitioning to Home
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft ambient cartoon backdrop with very low opacity (PRD Section 25)
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/backgrounds/bg_2.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Breathing Room + Centered Logo (PRD Section 3)
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle Rotating Sunburst
                    RotationTransition(
                      turns: _shineController,
                      child: Opacity(
                        opacity: 0.45,
                        child: Image.asset(
                          'assets/images/ui/shine.png',
                          width: 240,
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Clean, Centered Giggle Go! Logo
                    Image.asset(
                      'assets/images/trans-logo.png',
                      height: 180,
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
