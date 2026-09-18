import 'package:flutter/material.dart';

/// Giggle Go! Global Design System Tokens
/// Defined per UI/UX Correction & Visual Quality PRD (v1.0)

/// 4px Base Spacing Scale
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;
}

/// Standardized Corner Radii
class AppRadius {
  AppRadius._();

  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 18.0;
  static const double lg = 24.0;
  static const double xl = 28.0;
  static const double pill = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));
}

/// Semantic Colors & Category Theming
class AppColors {
  AppColors._();

  // Primary Theme
  static const Color primary = Color(0xFFFFAB40);
  static const Color primaryDark = Color(0xFFFF9100);
  static const Color secondary = Color(0xFF40C4FF);

  // Semantics
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F8EE);
  static const Color retry = Color(0xFFE53935);
  static const Color retryBg = Color(0xFFFFEBEE);

  // Neutral Backgrounds & Surfaces
  static const Color background = Color(0xFFFFFDF8);
  static const Color backgroundAlt = Color(0xFFFAF9F6);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEDF2F7);

  // Category Colors
  static const Color alphabet = Color(0xFF9C27B0);
  static const Color colors = Color(0xFFFF5252);
  static const Color fruits = Color(0xFF00B074);
  static const Color animals = Color(0xFFFF9500);
  static const Color vehicles = Color(0xFF0088FF);
  static const Color shapes = Color(0xFF5E35B1);

  // Tutorial Tokens
  static const Color tutorialBackdrop = Color(0xCC0F172A);
  static const Color tutorialHighlight = Color(0xFFFFD54F);

  // Category Gradients
  static const List<Color> gradientAlphabet = [Color(0xFF9C27B0), Color(0xFFBA68C8)];
  static const List<Color> gradientColors = [Color(0xFFFF5252), Color(0xFFFF7A45)];
  static const List<Color> gradientFruits = [Color(0xFF00B074), Color(0xFF52D68A)];
  static const List<Color> gradientAnimals = [Color(0xFFFF9500), Color(0xFFFF5E3A)];
  static const List<Color> gradientVehicles = [Color(0xFF0088FF), Color(0xFF00C6FF)];
  static const List<Color> gradientShapes = [Color(0xFF5E35B1), Color(0xFF7E57C2)];

  static Color forCategory(String id) {
    switch (id) {
      case 'alphabet': return alphabet;
      case 'colors': return colors;
      case 'fruits': return fruits;
      case 'animals': return animals;
      case 'vehicles': return vehicles;
      case 'shapes': return shapes;
      default: return primary;
    }
  }

  static List<Color> gradientForCategory(String id) {
    switch (id) {
      case 'alphabet': return gradientAlphabet;
      case 'colors': return gradientColors;
      case 'fruits': return gradientFruits;
      case 'animals': return gradientAnimals;
      case 'vehicles': return gradientVehicles;
      case 'shapes': return gradientShapes;
      default: return [primary, primaryDark];
    }
  }
}

/// 4 Semantic Typography Levels (PRD Section 9)
class AppTypography {
  AppTypography._();

  static const String fontDisplay = 'AnjaEliane';
  static const String fontBody = 'AlteHaasGrotesk';

  // Level 1: Brand
  static const TextStyle brand = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 26.0,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  // Level 2: Screen Title
  static const TextStyle screenTitle = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 20.0,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
    letterSpacing: 0.5,
  );

  /// Responsive brand / screen title font size for varying display widths.
  static double responsiveTitleSize(double screenWidth) {
    if (screenWidth < 360) return 20.0;
    if (screenWidth < 400) return 22.0;
    return 24.0;
  }

  // Level 3: Category / Primary Action
  static const TextStyle category = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 18.0,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
    letterSpacing: 0.4,
  );

  // Level 3 Variant: Card Title
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontDisplay,
    fontSize: 19.0,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: 0.4,
    shadows: [
      Shadow(
        color: Colors.black12,
        offset: Offset(0, 1),
        blurRadius: 3,
      ),
    ],
  );

  // Level 4: Supporting Text
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: fontBody,
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontBody,
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: Colors.white70,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontBody,
    fontSize: 13.0,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );
}

/// Subtle, purposeful elevations (PRD Section 27)
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> categoryCard(Color shadowColor) => [
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.28),
      blurRadius: 14,
      spreadRadius: 1,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];
}

/// Standardized component sizing targets (PRD Section 4, 7, 18, 20)
class AppSizes {
  AppSizes._();

  static const double headerHeight = 84.0;
  static const double minTouchTarget = 48.0;
  static const double iconButton = 48.0;
  static const double soundButtonTarget = 56.0;
  static const double childTarget = 64.0;
  static const double largePlayButton = 68.0;
  static const double minCardTap = 120.0;
  static const double categoryArtwork = 96.0;
  static const double learningTarget = 116.0;
  static const double mascotGuide = 84.0;
}
