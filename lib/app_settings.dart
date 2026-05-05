// lib/app_settings.dart
import 'package:flutter/material.dart';

class AppSettings {
  // الوضع الافتراضي: يتبع النظام
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  // null = يتبع النظام. وإلا Locale('ar') أو Locale('en')
  static final locale = ValueNotifier<Locale?>(null);

  static void toggleTheme() {
    final current = themeMode.value;
    themeMode.value =
        current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  static void toggleLocale() {
    final current = locale.value?.languageCode ?? 'en';
    locale.value = Locale(current == 'ar' ? 'en' : 'ar');
  }
}
