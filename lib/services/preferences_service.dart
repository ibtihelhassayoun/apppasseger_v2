import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'isDarkMode';
  static const String _languageKey = 'languageCode';
  static const String _notificationsKey = 'notificationsEnabled';
  
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isDarkMode => _prefs.getBool(_themeKey) ?? false;
  
  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_themeKey, value);
  }

  static String get language => _prefs.getString(_languageKey) ?? 'fr';
  
  static Future<void> setLanguage(String value) async {
    await _prefs.setString(_languageKey, value);
  }

  static bool get notificationsEnabled => _prefs.getBool(_notificationsKey) ?? true;
  
  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsKey, value);
  }
}
