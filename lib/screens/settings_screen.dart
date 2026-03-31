import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../main.dart'; // To access themeNotifier and localeNotifier
import '../services/preferences_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Provide default strings if localizations aren't loaded yet
    final l = localizations ?? AppLocalizations(const Locale('fr'));

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentTheme, _) {
          final isDark = currentTheme == ThemeMode.dark;

          return ListView(
            children: [
              SwitchListTile(
                title: Text(l.darkModeTitle),
                subtitle: Text(l.darkModeSubtitle),
                value: isDark,
                onChanged: (bool value) async {
                  themeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                  await PreferencesService.setDarkMode(value);
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: notificationsNotifier,
                builder: (context, notificationsEnabled, _) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: Text(l.notificationsTitle),
                    subtitle: Text(l.notificationsSubtitle),
                    value: notificationsEnabled,
                    onChanged: (bool value) async {
                      notificationsNotifier.value = value;
                      await PreferencesService.setNotificationsEnabled(value);
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l.languageTitle),
                subtitle: ValueListenableBuilder<Locale>(
                  valueListenable: localeNotifier,
                  builder: (context, locale, _) {
                    return Text(
                      locale.languageCode == 'fr' ? l.french : l.english,
                    );
                  },
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLanguageDialog(context, l);
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text(l.helpTitle),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l.helpTitle),
                      content: const Text(
                        'Contactez-nous à support@smarttransit.com pour obtenir de l\'aide.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(l.aboutTitle),
                subtitle: Text(l.aboutSubtitle),
                onTap: () {
                  // TODO: Show about dialog
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l.french),
                trailing: localeNotifier.value.languageCode == 'fr'
                    ? const Icon(Icons.check, color: Color(0xFF4CBDB6))
                    : null,
                onTap: () async {
                  localeNotifier.value = const Locale('fr');
                  await PreferencesService.setLanguage('fr');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(l.english),
                trailing: localeNotifier.value.languageCode == 'en'
                    ? const Icon(Icons.check, color: Color(0xFF4CBDB6))
                    : null,
                onTap: () async {
                  localeNotifier.value = const Locale('en');
                  await PreferencesService.setLanguage('en');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
