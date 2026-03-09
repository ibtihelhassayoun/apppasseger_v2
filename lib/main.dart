import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'services/preferences_service.dart';
import 'core/localization.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('fr'));
final ValueNotifier<bool> notificationsNotifier = ValueNotifier(true);
final ValueNotifier<int> alertCountNotifier = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await PreferencesService.init();
  themeNotifier.value = PreferencesService.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  localeNotifier.value = Locale(PreferencesService.language);
  notificationsNotifier.value = PreferencesService.notificationsEnabled;

  await Supabase.initialize(
    url: 'https://vtfwcyadplgllfpczziv.supabase.co',
    anonKey: 'sb_publishable_3GOOrL7R31uhow5LjzHTyw_Em45G1mC',
  );

  runApp(const PassengerApp());
}

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentThemeMode, _) {
            return MaterialApp(
              title: 'SmartTransit',
              debugShowCheckedModeBanner: false,
              locale: currentLocale,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('fr', ''),
                Locale('en', ''),
              ],
              themeMode: currentThemeMode,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF4CBDB6),
                  primary: const Color(0xFF4CBDB6),
                  secondary: const Color(0xFF11215D),
                  tertiary: const Color(0xFFFF748D),
                  surface: Colors.white,
                  brightness: Brightness.light,
                ),
                textTheme: const TextTheme(
                  headlineMedium: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11215D),
                  ),
                  titleLarge: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF11215D),
                  ),
                  bodyLarge: TextStyle(color: Color(0xFF11215D)),
                ),
                appBarTheme: const AppBarTheme(
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Color(0xFF11215D),
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11215D),
                  ),
                ),
                cardTheme: CardThemeData(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                ),
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFF4CBDB6).withValues(alpha: 0.2),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Color(0xFF4CBDB6));
                    }
                    return const IconThemeData(color: Colors.grey);
                  }),
                  labelTextStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              darkTheme: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF4CBDB6),
                  primary: const Color(0xFF4CBDB6),
                  brightness: Brightness.dark,
                ),
                // Additional dark theme configurations can be added here
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
