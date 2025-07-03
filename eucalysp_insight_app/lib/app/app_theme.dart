import 'package:flutter/material.dart';

// Define your brand colors based on the provided CSS
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color backgroundLight;
  final Color backgroundMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color error;
  final Color success;

  const AppThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.backgroundLight,
    required this.backgroundMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.error,
    required this.success,
  });

  // Light Theme Colors
  static const light = AppThemeColors(
    primary: Color(0xFF6200EE), // Material Design Purple
    primaryLight: Color(0xFF9E47FF),
    background: Color(0xFFFFFFFF),
    backgroundLight: Color(0xFFF5F5F5),
    backgroundMuted: Color(0xFFEEEEEE),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF444444),
    textMuted: Color(0xFF666666),
    textInverse: Color(0xFFFFFFFF),
    error: Color(0xFFB00020),
    success: Color(0xFF4CAF50), // Material Design Red
  );

  // Dark Theme Colors
  static const dark = AppThemeColors(
    primary: Color(0xFFBB86FC), // Material Design Purple for Dark Mode
    primaryLight: Color(0xFFD9BFFF),
    background: Color(0xFF121212), // Dark background
    backgroundLight: Color(0xFF1E1E1E),
    backgroundMuted: Color(0xFF2D2D2D),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFE0E0E0),
    textMuted: Color(0xFFB3B3B3),
    textInverse: Color(0xFF000000), // Black text on light primary accent
    error: Color(0xFFCF6679),
    success: Color(0xFFA5D6A7), // Material Design Red for Dark Mode
  );

  @override
  ThemeExtension<AppThemeColors> copyWith({
    Color? primary,
    Color? primaryLight,
    Color? background,
    Color? backgroundLight,
    Color? backgroundMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textInverse,
    Color? error,
    Color? success,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      background: background ?? this.background,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      backgroundMuted: backgroundMuted ?? this.backgroundMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      backgroundMuted: Color.lerp(backgroundMuted, other.backgroundMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

// Consolidate specific named colors that apply consistently
// or are base references for ColorScheme and ThemeExtension
class AppColors {
  // Primary Brand Colors (Original palette values)
  static const Color primary = Color(0xFF9333EA);
  static const Color primaryLight = Color(0xFFA855F7);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color primaryLighter = Color(0xFFC084FC);
  static const Color primaryDarker = Color(0xFF6D28D9);

  // Accent Colors
  static const Color accent1 = Color(0xFF000000); // Black
  static const Color accent2 = Color(0xFFFFFFFF); // White
  static const Color accent3 = Color(0xFF374151); // Dark Gray
  static const Color accent4 = Color(0xFFF3F4F6); // Light Gray

  // Text Colors
  static const Color textDark = Color(0xFF1F2937); // For light backgrounds
  static const Color textLight = Color(
    0xFF6B7280,
  ); // Lighter for light backgrounds
  static const Color textMuted = Color(
    0xFF9CA3AF,
  ); // Muted for light backgrounds, or general on dark
  static const Color textInverse = Color(0xFFFFFFFF); // For dark backgrounds
  // static const Color textPrimary = Color(0xFF9333EA); // Same as primary - can remove if using colorScheme.primary for text

  // Background Colors
  static const Color backgroundLight = Color(
    0xFFFFFFFF,
  ); // General light background
  static const Color backgroundDark = Color(
    0xFF1A1A1A,
  ); // General dark background
  static const Color backgroundMuted = Color(
    0xFFF9FAFB,
  ); // Very Light Gray, often for scaffolds
  static const Color backgroundOverlay = Color(
    0xCC1A1A1A,
  ); // rgba(26, 26, 26, 0.8) for scrims

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(
    0xFFFFE2E2,
  ); // Corrected Hex: 0xFFFEE2E2 to 0xFFFFE2E2
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFFDBEAFE);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB); // Light mode general border
  static const Color borderLight = Color(0xFFF3F4F6); // Lighter for light mode
  static const Color borderDark = Color(0xFF374151); // Dark mode general border
  static const Color borderPrimary = Color(
    0xFF9333EA,
  ); // Primary colored border
  static const Color borderFocus = Color(
    0xFFA855F7,
  ); // Border for focused states

  // Card Colors (using names that clearly distinguish light/dark if different)
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE5E7EB);
  static const Color cardBackgroundDark = Color(
    0xFF1F2937,
  ); // From dark mode override
  static const Color cardBorderDark = Color(
    0xFF374151,
  ); // From dark mode override
  static const Color cardShadow = Color(0x1A000000); // rgba(0, 0, 0, 0.1)
  static const Color cardHoverShadow = Color(
    0x269333EA,
  ); // rgba(147, 51, 234, 0.15)

  // Button hover/active states
  static const Color buttonPrimaryHover = Color(0xFF7C3AED);
  static const Color buttonPrimaryActive = Color(0xFF6D28D9);
  static const Color buttonSecondaryHover = Color(0xFFF9FAFB);
  static const Color buttonSecondaryActive = Color(0xFFF3F4F6);
}

// Global sizing values
class AppRadius {
  static const double sm = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double _2xl = 16.0;
  static const double full = 9999.0;
}

// --- Light Theme Definition ---

// Custom ColorScheme for your light theme
ColorScheme _lightColorScheme = ColorScheme(
  // Core colors
  primary: AppColors.primary,
  onPrimary: AppColors.textInverse, // Text/icons on primary (white)
  primaryContainer: AppColors.primaryLighter, // Lighter primary for containers
  onPrimaryContainer:
      AppColors.textDark, // Text on primary container (dark text)

  secondary:
      AppColors.accent3, // Using accent3 as a secondary tonal color for M3
  onSecondary: AppColors.textInverse, // Text/icons on secondary (white)
  secondaryContainer: AppColors.accent4, // Lighter accent3 for containers
  onSecondaryContainer:
      AppColors.textDark, // Text on secondary container (dark text)

  tertiary: AppColors.accent1, // Black can act as a strong tertiary accent
  onTertiary: AppColors.textInverse, // Text/icons on tertiary (white)
  tertiaryContainer: AppColors.accent3, // Dark grey for tertiary container
  onTertiaryContainer:
      AppColors.textInverse, // Text on tertiary container (white)

  error: AppColors.error,
  onError: AppColors.textInverse,
  errorContainer: AppColors.errorLight,
  onErrorContainer: AppColors.textDark,

  // Backgrounds and Surfaces
  background: AppColors
      .backgroundMuted, // Use muted background for general app background
  onBackground: AppColors.textDark, // Dark text on background
  surface: AppColors.backgroundLight, // Use light background for cards/sheets
  onSurface: AppColors.textDark, // Dark text on surface
  surfaceVariant:
      AppColors.accent4, // A slightly different surface color (light gray)
  onSurfaceVariant: AppColors.textLight, // Lighter text on surface variant
  // Other essential Material 3 colors
  outline: AppColors.border, // For borders around inputs, cards etc.
  shadow: AppColors.cardShadow, // Default shadow color
  inverseSurface:
      AppColors.backgroundDark, // Dark background for inverted surfaces
  onInverseSurface: AppColors.textInverse, // Light text on inverted surface
  inversePrimary:
      AppColors.primaryLight, // Lighter primary for inverted primary
  scrim: AppColors.backgroundOverlay, // For modal scrims

  brightness: Brightness.light,
);

// ThemeData for your light theme
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true, // Enable Material 3
    colorScheme: _lightColorScheme,
    extensions: const [AppThemeColors.light], // Apply extensions directly here
    // Define typography
    textTheme: TextTheme(
      // Headline styles (large, prominent text)
      displayLarge: TextStyle(
        fontSize: 57.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displayMedium: TextStyle(
        fontSize: 45.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displaySmall: TextStyle(
        fontSize: 36.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineLarge: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),

      // Title styles (medium-sized headings)
      titleLarge: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleSmall: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),

      // Body styles (main text content)
      bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textDark),
      bodyMedium: TextStyle(fontSize: 14.0, color: AppColors.textLight),
      bodySmall: TextStyle(fontSize: 12.0, color: AppColors.textMuted),

      // Label styles (for buttons, form fields, etc.)
      labelLarge: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
      ), // Default for buttons
      labelMedium: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      labelSmall: TextStyle(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
    ).apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark),

    // Common widget themes based on your CSS
    scaffoldBackgroundColor:
        AppColors.backgroundMuted, // Overall app background
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme
          .surface, // Use surface for AppBar to create a "floating" effect
      foregroundColor: _lightColorScheme.onSurface, // Text/icons on AppBar
      elevation: 2, // A subtle shadow for the app bar
      shadowColor: _lightColorScheme.shadow,
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: _lightColorScheme.onSurface),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // More rounded
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textInverse,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppRadius.xl,
              ), // radius-xl (12px)
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ), // MD sizing
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ), // ForeGroundColor will apply the text color
            elevation: 2, // subtle shadow
            shadowColor: AppColors.primary,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.buttonPrimaryHover;
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.buttonPrimaryActive;
              }
              return null;
            }),
          ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary, // Primary color for text buttons
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.borderPrimary),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl), // radius-xl
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ), // MD sizing
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          _lightColorScheme.surface, // Text fields have a light background
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg), // radius-lg (8px)
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderFocus, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 2.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textLight),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      floatingLabelStyle: TextStyle(color: _lightColorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    // Corrected type: CardTheme
    cardTheme: CardThemeData(
      color:
          AppColors.cardBackgroundLight, // Explicitly use light card background
      surfaceTintColor: Colors.transparent, // Prevents M3 tinting cards
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppRadius._2xl,
        ), // Adjusted for a slightly larger radius for cards (2xl)
        side: const BorderSide(
          color: AppColors.cardBorderLight,
        ), // Explicitly use light card border
      ),
      margin:
          EdgeInsets.zero, // Default no margin, use Padding widget around it
    ),
    // Corrected type: DialogTheme
    dialogTheme: DialogThemeData(
      backgroundColor: _lightColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius._2xl),
      ),
      titleTextStyle: TextStyle(
        color: _lightColorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      contentTextStyle: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 16,
    ),
  );
}

// --- Dark Theme Definition ---

ColorScheme _darkColorScheme = ColorScheme(
  // Core colors
  primary: AppThemeColors
      .dark
      .primary, // Use the primary color from the AppThemeColors.dark extension
  onPrimary: AppColors.textInverse, // Text/icons on primary (black)
  primaryContainer: AppColors.primaryDark,
  onPrimaryContainer: AppColors.textInverse,

  secondary: AppColors.accent4, // Lighter grey as secondary in dark mode
  onSecondary: AppColors.accent1, // Black text on secondary
  secondaryContainer: AppColors.accent3,
  onSecondaryContainer: AppColors.textInverse,

  tertiary: AppColors.accent2, // White as a tertiary accent in dark mode
  onTertiary: AppColors.accent1,
  tertiaryContainer: AppColors.accent4,
  onTertiaryContainer: AppColors.accent1,

  error: AppColors.error,
  onError: AppColors.textInverse,
  errorContainer: AppColors.errorLight,
  onErrorContainer: AppColors.textDark,

  // Backgrounds and Surfaces
  background: AppColors.backgroundDark, // Main dark background
  onBackground: AppColors.textLight, // Lighter text on dark background
  surface: AppColors.backgroundDark, // Dark surface for cards/sheets
  onSurface: AppColors.textLight, // Lighter text on dark surface
  surfaceVariant:
      AppColors.backgroundMuted, // A slightly different, darker surface variant
  onSurfaceVariant: AppColors.textMuted,

  // Other essential Material 3 colors
  outline: AppColors.borderDark, // Darker border in dark mode
  shadow: AppColors.cardShadow,
  inverseSurface: AppColors.backgroundLight,
  onInverseSurface: AppColors.textDark,
  inversePrimary: AppColors.primaryDark,
  scrim: AppColors.backgroundOverlay,

  brightness: Brightness.dark,
);

ThemeData buildDarkAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    extensions: const [AppThemeColors.dark], // Apply extensions directly here
    scaffoldBackgroundColor: AppColors.backgroundDark,
    textTheme:
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 57.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textInverse,
          ),
          displayMedium: TextStyle(
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textInverse,
          ),
          displaySmall: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textInverse,
          ),
          headlineLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textInverse,
          ),
          headlineMedium: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textInverse,
          ),
          headlineSmall: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textInverse,
          ),

          titleLarge: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          titleMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          titleSmall: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),

          bodyLarge: TextStyle(fontSize: 16.0, color: AppColors.textMuted),
          bodyMedium: TextStyle(fontSize: 14.0, color: AppColors.textMuted),
          bodySmall: TextStyle(fontSize: 12.0, color: AppColors.textMuted),

          labelLarge: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: AppColors.textInverse,
          ),
          labelMedium: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
          labelSmall: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ).apply(
          bodyColor: AppColors.textMuted,
          displayColor: AppColors.textInverse,
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 2,
      shadowColor: _darkColorScheme.shadow,
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: _darkColorScheme.onSurface),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, // Primary color is consistent
            foregroundColor: AppColors.textInverse,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ), // ForeGroundColor will apply the text color
            elevation: 2,
            shadowColor: AppColors.primary,
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.hovered)) {
                return AppColors.buttonPrimaryHover;
              }
              if (states.contains(WidgetState.pressed)) {
                return AppColors.buttonPrimaryActive;
              }
              return null;
            }),
          ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors
            .primaryLight, // Lighter primary for text buttons in dark mode
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: AppColors.borderPrimary,
        ), // Primary border color
        foregroundColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor:
          _darkColorScheme.surfaceVariant, // Darker fill for dark mode inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.borderFocus, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 2.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: TextStyle(
        color: AppColors.textMuted.withAlpha((255 * 0.7).round()),
      ),
      floatingLabelStyle: TextStyle(color: _darkColorScheme.primary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    // Corrected type: CardTheme
    cardTheme: CardThemeData(
      color:
          AppColors.cardBackgroundDark, // Use the specific dark card background
      surfaceTintColor: Colors.transparent,
      elevation: 4, // Slightly higher elevation for dark cards
      shadowColor: AppColors.cardShadow, // More prominent shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius._2xl),
        side: const BorderSide(
          color: AppColors.cardBorderDark,
        ), // Darker border for cards
      ),
      margin: EdgeInsets.zero,
    ),
    // Corrected type: DialogTheme
    dialogTheme: DialogThemeData(
      // FIX: Use _darkColorScheme for dark mode dialogs
      backgroundColor: _darkColorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius._2xl),
      ),
      titleTextStyle: TextStyle(
        color: _darkColorScheme.onSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      contentTextStyle: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontSize: 16,
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
      space: 16,
    ),
  );
}

// --- Gradients (Not part of ThemeData directly, but useful constants) ---
LinearGradient get primaryGradient => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primary, AppColors.primaryDark], // #9333EA to #7C3AED
);

LinearGradient get primaryToBlackGradient => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primary, AppColors.accent1], // #9333EA to #000000
);

LinearGradient get primaryToWhiteGradient => const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primary, AppColors.accent2], // #9333EA to #FFFFFF
);

LinearGradient get triBlendGradient => const LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  stops: [0.0, 0.5, 1.0],
  colors: [
    AppColors.primary,
    AppColors.accent2,
    AppColors.accent1,
  ], // #9333EA, #FFFFFF, #000000
);

RadialGradient get radialPrimaryGradient => const RadialGradient(
  center: Alignment.center,
  radius: 0.5,
  colors: [AppColors.primary, AppColors.accent1], // #9333EA to #000000
);

// Gradient for card premium in light mode
LinearGradient get cardGradientLight => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.primary, // rgba(147, 51, 234, 0.1)
    AppColors.accent1, // rgba(0, 0, 0, 0.05)
  ],
);

// Gradient for card premium in dark mode
LinearGradient get cardGradientDark => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColors.primary, // rgba(147, 51, 234, 0.15)
    AppColors.accent2, // rgba(255, 255, 255, 0.05)
  ],
);
