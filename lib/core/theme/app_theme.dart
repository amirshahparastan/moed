import 'package:flutter/material.dart';

class AppColors {
  static const blue = Color(0xFF3478F6);
  static const cyan = Color(0xFF72D5FF);
  static const purple = Color(0xFF8C75F6);
  static const navy = Color(0xFF102C5C);
  static const ink = Color(0xFF0C214B);
  static const muted = Color(0xFF7F8FAB);
  static const mutedDark = Color(0xFFB9C5D9);
  static const surface = Color(0xFFF2F7FF);
  static const success = Color(0xFF28B983);
  static const warning = Color(0xFFFFAD57);
  static const danger = Color(0xFFEF607A);
}

ThemeData buildTheme(Brightness brightness) {
  final bool dark = brightness == Brightness.dark;
  final Color mainText = dark ? const Color(0xFFF5F7FF) : AppColors.ink;
  final Color secondaryText = dark ? AppColors.mutedDark : AppColors.muted;
  final Color surface = dark ? const Color(0xFF18243A) : const Color(0xFFF8FBFF);

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
      primary: AppColors.blue,
      secondary: AppColors.purple,
      surface: surface,
      onSurface: mainText,
      onSurfaceVariant: secondaryText,
    ),
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: dark ? const Color(0xFF10192A) : AppColors.surface,
  );

  final textTheme = base.textTheme.apply(
    fontFamily: 'Vazirmatn',
    bodyColor: mainText,
    displayColor: mainText,
  ).copyWith(
    bodySmall: base.textTheme.bodySmall?.copyWith(fontFamily: 'Vazirmatn', fontSize: 12, height: 1.65),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(fontFamily: 'Vazirmatn', fontSize: 14, height: 1.65),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(fontFamily: 'Vazirmatn', fontSize: 16, height: 1.65),
    labelSmall: base.textTheme.labelSmall?.copyWith(fontFamily: 'Vazirmatn', fontSize: 12),
    labelMedium: base.textTheme.labelMedium?.copyWith(fontFamily: 'Vazirmatn', fontSize: 12),
    labelLarge: base.textTheme.labelLarge?.copyWith(fontFamily: 'Vazirmatn', fontSize: 14),
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    iconTheme: IconThemeData(color: dark ? const Color(0xFFDDE6F7) : AppColors.ink),
    dividerColor: dark ? Colors.white.withValues(alpha: .10) : const Color(0xFFE3EAF5),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: mainText,
      iconTheme: IconThemeData(color: mainText),
      actionsIconTheme: IconThemeData(color: mainText),
      titleTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        color: mainText,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? Colors.white.withValues(alpha: .065) : Colors.white.withValues(alpha: .76),
      labelStyle: TextStyle(color: secondaryText),
      hintStyle: TextStyle(color: secondaryText),
      prefixIconColor: secondaryText,
      suffixIconColor: secondaryText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: dark ? Colors.white.withValues(alpha: .10) : const Color(0xFFE2EBF8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.cyan, width: 1.4),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: mainText,
      iconColor: dark ? const Color(0xFFDDE6F7) : AppColors.ink,
      subtitleTextStyle: TextStyle(color: secondaryText, fontSize: 12),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: dark ? const Color(0xFF182235) : const Color(0xFFF9FBFF),
      titleTextStyle: TextStyle(color: mainText, fontSize: 18, fontWeight: FontWeight.w800),
      contentTextStyle: TextStyle(color: mainText),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? const Color(0xFF172134) : const Color(0xFFF9FBFF),
      modalBackgroundColor: dark ? const Color(0xFF172134) : const Color(0xFFF9FBFF),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: dark ? const Color(0xFF1A253A) : Colors.white,
      textStyle: TextStyle(color: mainText),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return dark ? Colors.white : AppColors.blue;
          return secondaryText;
        }),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: dark ? const Color(0xFF8AB4FF) : AppColors.blue,
        textStyle: TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: AppColors.blue.withValues(alpha: .10),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        return TextStyle(fontFamily: 'Vazirmatn', 
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? AppColors.blue : secondaryText,
        );
      }),
    ),
  );
}
