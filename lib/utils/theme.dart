import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
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