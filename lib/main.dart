import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/settings_screen.dart';


import 'app_settings.dart';
import 'screens/auth_gate.dart';
import 'screens/tasks_screen.dart';
import 'screens/task_setup_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';

const bool kSkipAuth = bool.fromEnvironment('SKIP_AUTH', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6750A4),
        brightness: b,
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (_, themeMode, __) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: AppSettings.locale,
          builder: (_, locale, __) {
            return MaterialApp(
              title: 'Smart Tasks AI',
              debugShowCheckedModeBanner: false,
              theme: _theme(Brightness.light),
              darkTheme: _theme(Brightness.dark),
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: kSkipAuth ? const TasksScreen() : const AuthGate(),
              routes: {
                '/settings': (_) => const SettingsScreen(),
                '/login': (_) => const LoginScreen(),
                '/tasks': (_) => const TasksScreen(),
                '/setup': (_) => const TaskSetupScreen(),
                '/chat': (_) => const ChatScreen(),
              },
            );
          },
        );
      },
    );
  }
}
