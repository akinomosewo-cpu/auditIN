import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary — single vibrant brand accent, used sparingly
  static const Color primary = Color(0xFFFF6A3D);
  static const Color primaryDark = Color(0xFFE0531F);
  static const Color primaryLight = Color(0xFFFF9166);

  // Status
  static const Color success = Color(0xFF2FBE7A);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF3FA7FF);

  // Power Band Colors — colorful, distinct chips for Band A..E
  static const Color bandA = Color(0xFF2FBE7A);
  static const Color bandB = Color(0xFF3FA7FF);
  static const Color bandC = Color(0xFFFFB020);
  static const Color bandD = Color(0xFFFF8A3D);
  static const Color bandE = Color(0xFFFF4D4F);

  // Neutrals — warm off-white / pastel light theme (app default)
  static const Color background = Color(0xFFFBF7F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF5EFE4);
  static const Color surfaceHighest = Color(0xFFEDE4D3);

  // Neutrals - Light (kept as aliases for the light theme getter)
  static const Color backgroundLight = Color(0xFFFBF7F1);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF5EFE4);

  // Text — warm light theme (app default)
  static const Color textPrimary = Color(0xFF1E1B16);
  static const Color textSecondary = Color(0xFF7A7368);
  static const Color textTertiary = Color(0xFFB8AF9E);

  // Text - Light mode (kept as aliases for the light theme getter)
  static const Color textPrimaryLight = Color(0xFF1E1B16);
  static const Color textSecondaryLight = Color(0xFF7A7368);
  static const Color textTertiaryLight = Color(0xFFB8AF9E);

  // Borders — used sparingly now; soft shadows do most of the separation
  static const Color border = Color(0xFFEFE7D8);
  static const Color borderLight = Color(0xFFEFE7D8);

  // Soft card shadow, used instead of flat borders
  static Color get cardShadow => const Color(0xFF1E1B16).withOpacity(0.06);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6A3D), Color(0xFFFF8A3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient powerOnGradient = LinearGradient(
    colors: [Color(0xFF2FBE7A), Color(0xFF34C759)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient powerOffGradient = LinearGradient(
    colors: [Color(0xFFFF4D4F), Color(0xFFFF6961)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF5EFE4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns the semantic accent color for a Band A..E label.
  static Color forBand(String bandKey) {
    switch (bandKey.toUpperCase()) {
      case 'A':
        return bandA;
      case 'B':
        return bandB;
      case 'C':
        return bandC;
      case 'D':
        return bandD;
      case 'E':
        return bandE;
      default:
        return primary;
    }
  }
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.12,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.18,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      );

  static TextStyle get monoMedium => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surface,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: AppTextStyles.headlineSmall,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: AppTextStyles.headlineSmall,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 0.5,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
          displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
          displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
          headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
          headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
          headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
          labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
      );

  /// The app's primary theme: a warm, soft light aesthetic with generous
  /// rounding, gentle shadows and a single vibrant accent color.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surfaceLight,
          error: AppColors.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimaryLight,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimaryLight,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: AppTextStyles.headlineSmall,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: AppTextStyles.headlineSmall,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 0.5,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimaryLight),
          displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimaryLight),
          displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimaryLight),
          headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimaryLight),
          headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimaryLight),
          headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimaryLight),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryLight),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
          labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryLight),
          labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight),
          labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondaryLight),
        ),
      );
}
