import 'package:flutter/material.dart';

class AppConstants {
  // SharedPreferences Keys
  static const String keyPrimaryColor = 'primary_color';
  static const String keySimColor = 'sim_color';
  static const String keyThumbnailSize = 'thumbnail_size';
  
  static const String keyGroupCalls = 'group_calls';
  static const String keyShowDividers = 'show_dividers';
  static const String keyHistoryLimit = 'history_limit';
  
  static const String keyVibrateOnAnswer = 'vibrate_on_answer';
  static const String keyVibrateOnEnd = 'vibrate_on_end';
  static const String keyDisableProximity = 'disable_proximity';
  
  static const String keyStartWithKeypad = 'start_with_keypad';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode'; // 'system', 'light', 'dark'

  // Defaults
  static const int defaultPrimaryColor = 0xFF2196F3; // Blue
  static const int defaultSimColor = 0xFF4CAF50; // Green
  static const double defaultThumbnailSize = 40.0;
  static const int defaultHistoryLimit = 2000;
}
