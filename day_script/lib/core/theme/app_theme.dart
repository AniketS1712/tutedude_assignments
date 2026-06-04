import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color seedColor = Color(0xFFE8A838);

  static const Color darkBackground = Color(0xFF1A1614);
  static const Color darkSurface = Color(0xFF231F1C);
  static const Color darkSurfaceVariant = Color(0xFF2D2824);

  static const Color moodNone = Color(0xFF9E9E9E);
  static const Color moodHappy = Color(0xFF4CAF50);
  static const Color moodSad = Color(0xFF2196F3);
  static const Color moodAngry = Color(0xFFF44336);
  static const Color moodTired = Color(0xFF9C27B0);
  static const Color moodExcited = Color(0xFFFF9800);
  static const Color moodAnxious = Color(0xFFFF5722);

  static Color getMoodColor(int moodIndex) {
    switch (moodIndex) {
      case 1:
        return moodHappy;
      case 2:
        return moodSad;
      case 3:
        return moodAngry;
      case 4:
        return moodTired;
      case 5:
        return moodExcited;
      case 6:
        return moodAnxious;
      default:
        return moodNone;
    }
  }

  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light({Color? seedColor}) {
    final seed = seedColor ?? AppColors.seedColor;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surfaceContainerLow,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 1,
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(128),
        thickness: 0.5,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
      ),
    );
  }

  static ThemeData dark({Color? seedColor}) {
    final seed = seedColor ?? AppColors.seedColor;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    final warmDarkScheme = colorScheme.copyWith(
      surface: AppColors.darkBackground,
      onSurface: const Color(0xFFE8E0D8),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: warmDarkScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: warmDarkScheme.onSurface,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: warmDarkScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.darkSurface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: warmDarkScheme.primaryContainer,
        foregroundColor: warmDarkScheme.onPrimaryContainer,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 1,
        indicatorColor: warmDarkScheme.secondaryContainer,
        backgroundColor: AppColors.darkSurface,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: warmDarkScheme.outlineVariant.withAlpha(78),
        thickness: 0.5,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? Colors.black87
        : const Color(0xFFE8E0D8);

    final headingStyle = GoogleFonts.playfairDisplay(color: textColor);
    final bodyStyle = GoogleFonts.inter(color: textColor);

    return TextTheme(
      displayLarge: headingStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: headingStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: headingStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: headingStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: headingStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: headingStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: headingStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: bodyStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}
