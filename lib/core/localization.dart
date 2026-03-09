import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'settings_title': 'Paramètres',
      'dark_mode_title': 'Mode Sombre',
      'dark_mode_subtitle': 'Activer le thème sombre',
      'notifications_title': 'Notifications',
      'notifications_subtitle': 'Activer les notifications push',
      'language_title': 'Langue',
      'language_subtitle': 'Français',
      'security_title': 'Sécurité et confidentialité',
      'help_title': 'Aide et support',
      'about_title': 'À propos',
      'about_subtitle': 'Version 1.0.0',
      'select_language': 'Sélectionner la langue',
      'french': 'Français',
      'english': 'English',
    },
    'en': {
      'settings_title': 'Settings',
      'dark_mode_title': 'Dark Mode',
      'dark_mode_subtitle': 'Enable dark theme',
      'notifications_title': 'Notifications',
      'notifications_subtitle': 'Enable push notifications',
      'language_title': 'Language',
      'language_subtitle': 'English',
      'security_title': 'Security & Privacy',
      'help_title': 'Help & Support',
      'about_title': 'About',
      'about_subtitle': 'Version 1.0.0',
      'select_language': 'Select Language',
      'french': 'Français',
      'english': 'English',
    },
  };

  String get settingsTitle => _localizedValues[locale.languageCode]?['settings_title'] ?? 'Settings';
  String get darkModeTitle => _localizedValues[locale.languageCode]?['dark_mode_title'] ?? 'Dark Mode';
  String get darkModeSubtitle => _localizedValues[locale.languageCode]?['dark_mode_subtitle'] ?? 'Enable dark theme';
  String get notificationsTitle => _localizedValues[locale.languageCode]?['notifications_title'] ?? 'Notifications';
  String get notificationsSubtitle => _localizedValues[locale.languageCode]?['notifications_subtitle'] ?? 'Enable push notifications';
  String get languageTitle => _localizedValues[locale.languageCode]?['language_title'] ?? 'Language';
  String get languageSubtitle => _localizedValues[locale.languageCode]?['language_subtitle'] ?? 'English';
  String get securityTitle => _localizedValues[locale.languageCode]?['security_title'] ?? 'Security & Privacy';
  String get helpTitle => _localizedValues[locale.languageCode]?['help_title'] ?? 'Help & Support';
  String get aboutTitle => _localizedValues[locale.languageCode]?['about_title'] ?? 'About';
  String get aboutSubtitle => _localizedValues[locale.languageCode]?['about_subtitle'] ?? 'Version 1.0.0';
  String get selectLanguage => _localizedValues[locale.languageCode]?['select_language'] ?? 'Select Language';
  String get french => _localizedValues[locale.languageCode]?['french'] ?? 'Français';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
