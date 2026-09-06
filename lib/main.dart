import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation (PRD requirement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const GiggleGoApp());
}

class GiggleGoApp extends StatelessWidget {
  const GiggleGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giggle Go!',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        // Color scheme anchored to warm orange-yellow
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFAB40),
          brightness: Brightness.light,
          primary: const Color(0xFFFFAB40),
          secondary: const Color(0xFF40C4FF),
          surface: const Color(0xFFFFF8E1),
          error: const Color(0xFFEF5350),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFAB40),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        // ElevatedButton defaults
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFAB40),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0x66FFAB40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}
