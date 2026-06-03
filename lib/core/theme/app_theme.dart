import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_sum/core/theme/app_colors.dart';
import 'package:spend_sum/core/theme/app_dimensions.dart';

/// AppTheme manages the SpendSum application light and dark theme configurations.
class AppTheme {
  AppTheme._();

  // --- Light Theme Colors ---
  static const Color lightPrimary = Color(0xFF6638E5);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFF7F56FF);
  static const Color lightOnPrimaryContainer = Color(0xFF060022);
  static const Color lightInversePrimary = Color(0xFFCCBDFF);
  
  static const Color lightSecondary = Color(0xFF006C44);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFF6FFCB5);
  static const Color lightOnSecondaryContainer = Color(0xFF007349);

  static const Color lightTertiary = Color(0xFF0060A8);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFF0079D2);
  static const Color lightOnTertiaryContainer = Color(0xFFFFFFFF);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);

  static const Color lightBackground = Color(0xFFFBF8FF);
  static const Color lightOnBackground = Color(0xFF1B1B20);

  static const Color lightSurface = Color(0xFFFBF8FF);
  static const Color lightOnSurface = Color(0xFF1B1B20);
  static const Color lightSurfaceVariant = Color(0xFFE4E1E9);
  
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);

  static const Color lightOutline = Color(0xFF7A7487);
  static const Color lightOutlineVariant = Color(0xFFCAC3D8);
  static const Color lightInverseSurface = Color(0xFF303035);
  static const Color lightInverseOnSurface = Color(0xFFF3EFF7);
  static const Color lightSurfaceTint = Color(0xFF6638E5);

  static const Color lightSurfaceDim = Color(0xFFDCD9E0);
  static const Color lightSurfaceBright = Color(0xFFFBF8FF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF6F2FA);
  static const Color lightSurfaceContainer = Color(0xFFF0ECF4);
  static const Color lightSurfaceContainerHigh = Color(0xFFEAE7EE);
  static const Color lightSurfaceContainerHighest = Color(0xFFE4E1E9);

  static const Color lightPrimaryFixed = Color(0xFFE7DEFF);
  static const Color lightPrimaryFixedDim = Color(0xFFCCBDFF);
  static const Color lightOnPrimaryFixed = Color(0xFF1F0060);
  static const Color lightOnPrimaryFixedVariant = Color(0xFF4D0ACD);

  static const Color lightSecondaryFixed = Color(0xFF6FFCB5);
  static const Color lightSecondaryFixedDim = Color(0xFF4FDF9B);
  static const Color lightOnSecondaryFixed = Color(0xFF002112);
  static const Color lightOnSecondaryFixedVariant = Color(0xFF005232);

  static const Color lightTertiaryFixed = Color(0xFFD3E4FF);
  static const Color lightTertiaryFixedDim = Color(0xFFA2C9FF);
  static const Color lightOnTertiaryFixed = Color(0xFF001C38);
  static const Color lightOnTertiaryFixedVariant = Color(0xFF004881);

  // --- Dark Theme Colors ---
  static const Color darkPrimary = Color(0xFFCCBDFF);
  static const Color darkOnPrimary = Color(0xFF350097);
  static const Color darkPrimaryContainer = Color(0xFF7F56FF);
  static const Color darkOnPrimaryContainer = Color(0xFF060022);
  static const Color darkInversePrimary = Color(0xFF6638E5);

  static const Color darkSecondary = Color(0xFF4FDF9B);
  static const Color darkOnSecondary = Color(0xFF003821);
  static const Color darkSecondaryContainer = Color(0xFF00B475);
  static const Color darkOnSecondaryContainer = Color(0xFF003E25);

  static const Color darkTertiary = Color(0xFFA2C9FF);
  static const Color darkOnTertiary = Color(0xFF00315B);
  static const Color darkTertiaryContainer = Color(0xFF0079D2);
  static const Color darkOnTertiaryContainer = Color(0xFFFFFFFF);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkBackground = Color(0xFF131318);
  static const Color darkOnBackground = Color(0xFFE4E1E9);

  static const Color darkSurface = Color(0xFF131318);
  static const Color darkOnSurface = Color(0xFFE4E1E9);
  static const Color darkSurfaceVariant = Color(0xFF35343A);
  
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF);

  static const Color darkOutline = Color(0xFF948EA1);
  static const Color darkOutlineVariant = Color(0xFF494455);
  static const Color darkInverseSurface = Color(0xFFE4E1E9);
  static const Color darkInverseOnSurface = Color(0xFF303035);
  static const Color darkSurfaceTint = Color(0xFFCCBDFF);

  static const Color darkSurfaceDim = Color(0xFF131318);
  static const Color darkSurfaceBright = Color(0xFF39393E);
  static const Color darkSurfaceContainerLowest = Color(0xFF0E0E13);
  static const Color darkSurfaceContainerLow = Color(0xFF1B1B20);
  static const Color darkSurfaceContainer = Color(0xFF1F1F24);
  static const Color darkSurfaceContainerHigh = Color(0xFF2A292F);
  static const Color darkSurfaceContainerHighest = Color(0xFF35343A);

  static const Color darkPrimaryFixed = Color(0xFFE7DEFF);
  static const Color darkPrimaryFixedDim = Color(0xFFCCBDFF);
  static const Color darkOnPrimaryFixed = Color(0xFF1F0060);
  static const Color darkOnPrimaryFixedVariant = Color(0xFF4D0ACD);

  static const Color darkSecondaryFixed = Color(0xFF6FFCB5);
  static const Color darkSecondaryFixedDim = Color(0xFF4FDF9B);
  static const Color darkOnSecondaryFixed = Color(0xFF002112);
  static const Color darkOnSecondaryFixedVariant = Color(0xFF005232);

  static const Color darkTertiaryFixed = Color(0xFFD3E4FF);
  static const Color darkTertiaryFixedDim = Color(0xFFA2C9FF);
  static const Color darkOnTertiaryFixed = Color(0xFF001C38);
  static const Color darkOnTertiaryFixedVariant = Color(0xFF004881);

  // --- Static AppThemeExtension Single Source of Truth ---
  static const AppThemeExtension lightExtension = AppThemeExtension(
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    error: lightError,
    onError: lightOnError,
    errorContainer: lightErrorContainer,
    onErrorContainer: lightOnErrorContainer,
    background: lightBackground,
    onBackground: lightOnBackground,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceVariant: lightSurfaceVariant,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    inverseSurface: lightInverseSurface,
    inverseOnSurface: lightInverseOnSurface,
    inversePrimary: lightInversePrimary,
    surfaceTint: lightSurfaceTint,
    surfaceDim: lightSurfaceDim,
    surfaceBright: lightSurfaceBright,
    surfaceContainerLowest: lightSurfaceContainerLowest,
    surfaceContainerLow: lightSurfaceContainerLow,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHigh: lightSurfaceContainerHigh,
    surfaceContainerHighest: lightSurfaceContainerHighest,
    primaryFixed: lightPrimaryFixed,
    primaryFixedDim: lightPrimaryFixedDim,
    onPrimaryFixed: lightOnPrimaryFixed,
    onPrimaryFixedVariant: lightOnPrimaryFixedVariant,
    secondaryFixed: lightSecondaryFixed,
    secondaryFixedDim: lightSecondaryFixedDim,
    onSecondaryFixed: lightOnSecondaryFixed,
    onSecondaryFixedVariant: lightOnSecondaryFixedVariant,
    tertiaryFixed: lightTertiaryFixed,
    tertiaryFixedDim: lightTertiaryFixedDim,
    onTertiaryFixed: lightOnTertiaryFixed,
    onTertiaryFixedVariant: lightOnTertiaryFixedVariant,
    backgroundGradientStart: Color(0xFFE2D6FF),
    backgroundGradientEnd: lightBackground,
    cardColor: Colors.white,
  );

  static const AppThemeExtension darkExtension = AppThemeExtension(
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    background: darkBackground,
    onBackground: darkOnBackground,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceVariant: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    inverseSurface: darkInverseSurface,
    inverseOnSurface: darkInverseOnSurface,
    inversePrimary: darkInversePrimary,
    surfaceTint: darkSurfaceTint,
    surfaceDim: darkSurfaceDim,
    surfaceBright: darkSurfaceBright,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    primaryFixed: darkPrimaryFixed,
    primaryFixedDim: darkPrimaryFixedDim,
    onPrimaryFixed: darkOnPrimaryFixed,
    onPrimaryFixedVariant: darkOnPrimaryFixedVariant,
    secondaryFixed: darkSecondaryFixed,
    secondaryFixedDim: darkSecondaryFixedDim,
    onSecondaryFixed: darkOnSecondaryFixed,
    onSecondaryFixedVariant: darkOnSecondaryFixedVariant,
    tertiaryFixed: darkTertiaryFixed,
    tertiaryFixedDim: darkTertiaryFixedDim,
    onTertiaryFixed: darkOnTertiaryFixed,
    onTertiaryFixedVariant: darkOnTertiaryFixedVariant,
    backgroundGradientStart: Color(0xFF201648),
    backgroundGradientEnd: darkBackground,
    cardColor: darkSurfaceContainer,
  );

  /// Helper to build typographic styling according to the design specifications.
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700, // Bold
        height: 40 / 32,
        letterSpacing: -0.02,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600, // Semi-Bold
        height: 32 / 24,
        letterSpacing: -0.01,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600, // Semi-Bold
        height: 28 / 20,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular
        height: 24 / 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        height: 20 / 14,
        color: textColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600, // Semi-Bold
        height: 20 / 14,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium
        height: 16 / 12,
        color: textColor,
      ),
    );
  }

  /// Light theme definition.
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightExtension.primary,
      onPrimary: lightExtension.onPrimary,
      primaryContainer: lightExtension.primaryContainer,
      onPrimaryContainer: lightExtension.onPrimaryContainer,
      secondary: lightExtension.secondary,
      onSecondary: lightExtension.onSecondary,
      secondaryContainer: lightExtension.secondaryContainer,
      onSecondaryContainer: lightExtension.onSecondaryContainer,
      tertiary: lightExtension.tertiary,
      onTertiary: lightExtension.onTertiary,
      tertiaryContainer: lightExtension.tertiaryContainer,
      onTertiaryContainer: lightExtension.onTertiaryContainer,
      error: lightExtension.error,
      onError: lightExtension.onError,
      errorContainer: lightExtension.errorContainer,
      onErrorContainer: lightExtension.onErrorContainer,
      surface: lightExtension.surface,
      onSurface: lightExtension.onSurface,
      onSurfaceVariant: lightExtension.onSurfaceVariant,
      outline: lightExtension.outline,
      outlineVariant: lightExtension.outlineVariant,
      inverseSurface: lightExtension.inverseSurface,
      onInverseSurface: lightExtension.inverseOnSurface,
      inversePrimary: lightExtension.inversePrimary,
      surfaceTint: lightExtension.surfaceTint,
      surfaceDim: lightExtension.surfaceDim,
      surfaceBright: lightExtension.surfaceBright,
      surfaceContainerLowest: lightExtension.surfaceContainerLowest,
      surfaceContainerLow: lightExtension.surfaceContainerLow,
      surfaceContainer: lightExtension.surfaceContainer,
      surfaceContainerHigh: lightExtension.surfaceContainerHigh,
      surfaceContainerHighest: lightExtension.surfaceContainerHighest,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightExtension.background,
      cardColor: lightExtension.cardColor,
      textTheme: _buildTextTheme(base.textTheme, lightExtension.onSurface),
      
      // Card Theme config
      cardTheme: CardThemeData(
        color: lightExtension.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl), // 48px
          side: const BorderSide(color: lightOutlineVariant, width: 1),
        ),
      ),

      // Buttons styling mapping to specs
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightExtension.primary,
          foregroundColor: lightExtension.onPrimary,
          minimumSize: const Size(88, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 32px
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightExtension.onSurface,
          backgroundColor: lightExtension.surfaceContainer,
          side: const BorderSide(color: lightOutline, width: 1),
          minimumSize: const Size(88, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 32px
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input field styling mapping to specs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightExtension.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 32px
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: lightPrimary, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightOnSurfaceVariant,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),

      // Extensions
      extensions: [
        lightExtension,
        AppTextThemeExtension(
          headlineLgMobile: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 28 / 22,
            color: lightExtension.onSurface,
          ),
        ),
      ],
    );
  }

  /// Dark theme definition.
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkExtension.primary,
      onPrimary: darkExtension.onPrimary,
      primaryContainer: darkExtension.primaryContainer,
      onPrimaryContainer: darkExtension.onPrimaryContainer,
      secondary: darkExtension.secondary,
      onSecondary: darkExtension.onSecondary,
      secondaryContainer: darkExtension.secondaryContainer,
      onSecondaryContainer: darkExtension.onSecondaryContainer,
      tertiary: darkExtension.tertiary,
      onTertiary: darkExtension.onTertiary,
      tertiaryContainer: darkExtension.tertiaryContainer,
      onTertiaryContainer: darkExtension.onTertiaryContainer,
      error: darkExtension.error,
      onError: darkExtension.onError,
      errorContainer: darkExtension.errorContainer,
      onErrorContainer: darkExtension.onErrorContainer,
      surface: darkExtension.surface,
      onSurface: darkExtension.onSurface,
      onSurfaceVariant: darkExtension.onSurfaceVariant,
      outline: darkExtension.outline,
      outlineVariant: darkExtension.outlineVariant,
      inverseSurface: darkExtension.inverseSurface,
      onInverseSurface: darkExtension.inverseOnSurface,
      inversePrimary: darkExtension.inversePrimary,
      surfaceTint: darkExtension.surfaceTint,
      surfaceDim: darkExtension.surfaceDim,
      surfaceBright: darkExtension.surfaceBright,
      surfaceContainerLowest: darkExtension.surfaceContainerLowest,
      surfaceContainerLow: darkExtension.surfaceContainerLow,
      surfaceContainer: darkExtension.surfaceContainer,
      surfaceContainerHigh: darkExtension.surfaceContainerHigh,
      surfaceContainerHighest: darkExtension.surfaceContainerHighest,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkExtension.background,
      cardColor: darkExtension.cardColor,
      textTheme: _buildTextTheme(base.textTheme, darkExtension.onSurface),
      
      // Card Theme config
      cardTheme: CardThemeData(
        color: darkExtension.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl), // 48px
          side: const BorderSide(color: darkOutlineVariant, width: 1),
        ),
      ),

      // Buttons styling mapping to specs
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkExtension.primaryContainer,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 32px
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkExtension.onSurface,
          backgroundColor: darkExtension.surfaceContainer,
          side: const BorderSide(color: darkOutline, width: 1),
          minimumSize: const Size(88, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 32px
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input field styling mapping to specs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkExtension.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg), // 32px
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkOnSurfaceVariant,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),

      // Extensions
      extensions: [
        darkExtension,
        AppTextThemeExtension(
          headlineLgMobile: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 28 / 22,
            color: darkExtension.onSurface,
          ),
        ),
      ],
    );
  }
}
