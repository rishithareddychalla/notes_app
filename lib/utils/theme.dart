import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFE3E0FF), // Lavender Purple
  scaffoldBackgroundColor: const Color(0xFFF0F4F8), // Cloud Gray
  cardColor: const Color(0xFFFFFFFF), // White
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFE3E0FF), // Lavender Purple
    iconTheme: IconThemeData(color: Color(0xFF333333)),
    titleTextStyle: TextStyle(
        color: Color(0xFF333333), fontSize: 20, fontWeight: FontWeight.bold),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFCDE7F0), // Powder Blue
    foregroundColor: Color(0xFF333333),
  ),
  dividerColor: const Color(0xFFD0F0F8), // Baby Blue
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFF333333)),
    bodyLarge: TextStyle(color: Color(0xFF333333)),
    titleMedium: TextStyle(color: Color(0xFF333333)),
    titleLarge: TextStyle(color: Color(0xFF333333)),
    headlineSmall: TextStyle(color: Color(0xFF333333)),
    headlineMedium: TextStyle(color: Color(0xFF333333)),
    headlineLarge: TextStyle(color: Color(0xFF333333)),
  ).apply(
    bodyColor: const Color(0xFF333333),
    displayColor: const Color(0xFF333333),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF666666)),
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.light).copyWith(
    secondary: const Color(0xFFCDE7F0), // Powder Blue
    surface: const Color(0xFFFFFFFF), // White
    onSurface: const Color(0xFF333333),
    primary: const Color(0xFFE3E0FF), // Lavender Purple
    onPrimary: const Color(0xFF333333),
    secondaryContainer: const Color(0xFFD0F0F8), // Baby Blue
    onSecondaryContainer: const Color(0xFF333333),
    tertiary: const Color(0xFFE0F7FA), // Aqua Mint
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