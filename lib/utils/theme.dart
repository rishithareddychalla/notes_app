import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF333333),
  scaffoldBackgroundColor: const Color(0xFFF9F9F9),
  cardColor: const Color(0xFFFFF9F0),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF5F5F5),
    iconTheme: IconThemeData(color: Color(0xFF333333)),
    titleTextStyle: TextStyle(
        color: Color(0xFF333333), fontSize: 20, fontWeight: FontWeight.bold),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF82CFFD),
    foregroundColor: Colors.white,
  ),
  dividerColor: const Color(0xFFE0E0E0),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF222222)),
    bodyLarge: TextStyle(color: Color(0xFF222222)),
    titleMedium: TextStyle(color: Color(0xFF222222)),
    titleLarge: TextStyle(color: Color(0xFF222222)),
    headlineSmall: TextStyle(color: Color(0xFF222222)),
    headlineMedium: TextStyle(color: Color(0xFF222222)),
    headlineLarge: TextStyle(color: Color(0xFF222222)),
  ).apply(
    bodyColor: const Color(0xFF222222),
    displayColor: const Color(0xFF222222),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF666666)),
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.light).copyWith(
    secondary: const Color(0xFF82CFFD),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF222222),
    primary: const Color(0xFF333333),
    onPrimary: Colors.white,
    secondaryContainer: const Color(0xFFDDEFFF),
    onSecondaryContainer: const Color(0xFF333333),
    tertiary: const Color(0xFFCCE5FF),
    onTertiary: const Color(0xFF333333),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.grey[850],
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
  ),
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
      .copyWith(secondary: Colors.blueAccent),
);