import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Appearance
  int _primaryColor = AppConstants.defaultPrimaryColor;
  int _simColor = AppConstants.defaultSimColor;
  double _thumbnailSize = AppConstants.defaultThumbnailSize;
  ThemeMode _themeMode = ThemeMode.system;

  // List View
  bool _groupCalls = true;
  bool _showDividers = true;
  int _historyLimit = AppConstants.defaultHistoryLimit;

  // Calls
  bool _vibrateOnAnswer = false;
  bool _vibrateOnEnd = false;
  bool _disableProximity = false;

  // General
  bool _startWithKeypad = false;
  String _language = 'en';

  // Getters
  bool get isInitialized => _isInitialized;
  Color get primaryColor => Color(_primaryColor);
  Color get simColor => Color(_simColor);
  double get thumbnailSize => _thumbnailSize;
  ThemeMode get themeMode => _themeMode;

  bool get groupCalls => _groupCalls;
  bool get showDividers => _showDividers;
  int get historyLimit => _historyLimit;

  bool get vibrateOnAnswer => _vibrateOnAnswer;
  bool get vibrateOnEnd => _vibrateOnEnd;
  bool get disableProximity => _disableProximity;

  bool get startWithKeypad => _startWithKeypad;
  String get language => _language;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    _primaryColor = _prefs.getInt(AppConstants.keyPrimaryColor) ?? AppConstants.defaultPrimaryColor;
    _simColor = _prefs.getInt(AppConstants.keySimColor) ?? AppConstants.defaultSimColor;
    _thumbnailSize = _prefs.getDouble(AppConstants.keyThumbnailSize) ?? AppConstants.defaultThumbnailSize;
    
    String themeModeString = _prefs.getString(AppConstants.keyThemeMode) ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);

    _groupCalls = _prefs.getBool(AppConstants.keyGroupCalls) ?? true;
    _showDividers = _prefs.getBool(AppConstants.keyShowDividers) ?? true;
    _historyLimit = _prefs.getInt(AppConstants.keyHistoryLimit) ?? AppConstants.defaultHistoryLimit;

    _vibrateOnAnswer = _prefs.getBool(AppConstants.keyVibrateOnAnswer) ?? false;
    _vibrateOnEnd = _prefs.getBool(AppConstants.keyVibrateOnEnd) ?? false;
    _disableProximity = _prefs.getBool(AppConstants.keyDisableProximity) ?? false;

    _startWithKeypad = _prefs.getBool(AppConstants.keyStartWithKeypad) ?? false;
    _language = _prefs.getString(AppConstants.keyLanguage) ?? 'en';

    _isInitialized = true;
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      default: return 'system';
    }
  }

  // Setters
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color.value;
    await _prefs.setInt(AppConstants.keyPrimaryColor, _primaryColor);
    notifyListeners();
  }

  Future<void> setSimColor(Color color) async {
    _simColor = color.value;
    await _prefs.setInt(AppConstants.keySimColor, _simColor);
    notifyListeners();
  }

  Future<void> setThumbnailSize(double size) async {
    _thumbnailSize = size;
    await _prefs.setDouble(AppConstants.keyThumbnailSize, size);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(AppConstants.keyThemeMode, _themeModeToString(mode));
    notifyListeners();
  }

  Future<void> setGroupCalls(bool value) async {
    _groupCalls = value;
    await _prefs.setBool(AppConstants.keyGroupCalls, value);
    notifyListeners();
  }

  Future<void> setShowDividers(bool value) async {
    _showDividers = value;
    await _prefs.setBool(AppConstants.keyShowDividers, value);
    notifyListeners();
  }

  Future<void> setHistoryLimit(int value) async {
    _historyLimit = value;
    await _prefs.setInt(AppConstants.keyHistoryLimit, value);
    notifyListeners();
  }

  Future<void> setVibrateOnAnswer(bool value) async {
    _vibrateOnAnswer = value;
    await _prefs.setBool(AppConstants.keyVibrateOnAnswer, value);
    notifyListeners();
  }

  Future<void> setVibrateOnEnd(bool value) async {
    _vibrateOnEnd = value;
    await _prefs.setBool(AppConstants.keyVibrateOnEnd, value);
    notifyListeners();
  }

  Future<void> setDisableProximity(bool value) async {
    _disableProximity = value;
    await _prefs.setBool(AppConstants.keyDisableProximity, value);
    notifyListeners();
  }

  Future<void> setStartWithKeypad(bool value) async {
    _startWithKeypad = value;
    await _prefs.setBool(AppConstants.keyStartWithKeypad, value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _prefs.setString(AppConstants.keyLanguage, value);
    notifyListeners();
  }
}
