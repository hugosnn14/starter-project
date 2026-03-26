import 'package:flutter/material.dart';

class AppPalette {
  static const Color background = Color(0xFFFDF8FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF7F2FA);
  static const Color surfaceContainer = Color(0xFFF2ECF6);
  static const Color surfaceHigh = Color(0xFFECE6F1);
  static const Color outline = Color(0xFFE6E0EC);
  static const Color primary = Color(0xFF6933EB);
  static const Color primaryContainer = Color(0xFF7D4CFF);
  static const Color secondary = Color(0xFF526074);
  static const Color secondaryContainer = Color(0xFFD5E3FC);
  static const Color onSecondaryContainer = Color(0xFF455367);
  static const Color onSurface = Color(0xFF34313A);
  static const Color onSurfaceMuted = Color(0xFF615D68);
  static const Color error = Color(0xFFA8364B);
  static const Color errorContainer = Color(0xFFF97386);
  static const Color onErrorContainer = Color(0xFF6E0523);
  static const Color shadow = Color.fromRGBO(52, 49, 58, 0.08);
}

ThemeData theme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppPalette.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.primaryContainer,
    onPrimaryContainer: Colors.white,
    secondary: AppPalette.secondary,
    secondaryContainer: AppPalette.secondaryContainer,
    onSecondaryContainer: AppPalette.onSecondaryContainer,
    surface: AppPalette.surface,
    onSurface: AppPalette.onSurface,
    error: AppPalette.error,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
    outline: AppPalette.outline,
  );

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.background,
    fontFamily: 'Muli',
  );

  return baseTheme.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppPalette.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppPalette.onSurface),
      titleTextStyle: TextStyle(
        color: AppPalette.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppPalette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppPalette.outline),
      ),
    ),
    dividerColor: AppPalette.outline,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.onSurface,
      contentTextStyle: baseTheme.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppPalette.surfaceHigh,
        disabledForegroundColor: AppPalette.onSurfaceMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.surface,
      labelStyle: const TextStyle(
        color: AppPalette.onSurfaceMuted,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(
        color: AppPalette.onSurfaceMuted,
      ),
      errorStyle: const TextStyle(
        color: AppPalette.error,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(color: AppPalette.primary),
      errorBorder: _inputBorder(color: AppPalette.error),
      focusedErrorBorder: _inputBorder(color: AppPalette.error),
    ),
    textTheme: baseTheme.textTheme.copyWith(
      displaySmall: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: AppPalette.onSurface,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: AppPalette.onSurface,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: AppPalette.onSurface,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppPalette.onSurface,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.55,
        color: AppPalette.onSurface,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppPalette.onSurfaceMuted,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppPalette.onSurface,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppPalette.onSurfaceMuted,
      ),
    ),
  );
}

OutlineInputBorder _inputBorder({Color color = AppPalette.outline}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(20),
    borderSide: BorderSide(color: color),
  );
}
