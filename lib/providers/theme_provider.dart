import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_provider.dart';

class ThemeProvider {
  final SettingsProvider settings;

  ThemeProvider(this.settings);

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: settings.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: settings.primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: settings.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: settings.primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: settings.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeMode get themeMode => settings.themeMode;
}
