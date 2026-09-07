import 'package:flutter/material.dart';
import '../widgets/smooth_mascot.dart';
import 'home_screen.dart';

/// Splash screen — shows for ~2 seconds with a bounce animation, then navigates to Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _controller.forward();

    // Navigate to Home after 2.4s
    Future.delayed(const Duration(milliseconds: 2400), () {
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
    _controller.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-bleed illustrated landscape background
          Image.asset(
            'assets/images/backgrounds/bg_2.png',
            fit: BoxFit.cover,
          ),
          // Soft translucent gradient overlay for optimal contrast
          Container(
            color: Colors.white.withValues(alpha: 0.18),
          ),
          // Centered animated branding & mascot
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hero Brand Logo with Radiant Rotating Sunburst
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _shineController,
                            child: Opacity(
                              opacity: 0.65,
                              child: Image.asset(
                                'assets/images/ui/shine.png',
                                width: 210,
                                height: 210,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/trans-logo.png',
                            height: 150,
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Cheerful Companion Cat Mascot celebrating
                      const SmoothMascot(
                        action: 'celebrate',
                        size: 92,
                      ),
                      const SizedBox(height: 12),

                      // Playful Preschool Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('✨', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              'Learn, Play & Giggle!',
                              style: TextStyle(
                                fontFamily: 'AnjaEliane',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0284C7),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('🎈', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
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
