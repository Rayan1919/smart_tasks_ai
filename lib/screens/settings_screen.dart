import 'package:flutter/material.dart';
import '../app_settings.dart';
import '../i18n/strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(S.t(context, 'settings'))),
      body: Container(
        color: cs.surfaceVariant.withOpacity(.2),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _AppearanceSection(),
                SizedBox(height: 16),
                _LanguageSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: AppSettings.themeMode,
          builder: (_, mode, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.t(context, 'appearance'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: mode,
                  onChanged: (v) => AppSettings.themeMode.value = v!,
                  title: Text(S.t(context, 'theme_system')),
                  secondary: const Icon(Icons.auto_mode),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: mode,
                  onChanged: (v) => AppSettings.themeMode.value = v!,
                  title: Text(S.t(context, 'theme_light')),
                  secondary: const Icon(Icons.light_mode),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: mode,
                  onChanged: (v) => AppSettings.themeMode.value = v!,
                  title: Text(S.t(context, 'theme_dark')),
                  secondary: const Icon(Icons.dark_mode),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<Locale?>(
          valueListenable: AppSettings.locale,
          builder: (_, loc, __) {
            final code = loc?.languageCode;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.t(context, 'language'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                RadioListTile<String?>(
                  value: null, // system
                  groupValue: code,
                  onChanged: (_) => AppSettings.locale.value = null,
                  title: Text(S.t(context, 'lang_system')),
                  secondary: const Icon(Icons.phone_android),
                ),
                RadioListTile<String?>(
                  value: 'en',
                  groupValue: code,
                  onChanged: (_) => AppSettings.locale.value = const Locale('en'),
                  title: Text(S.t(context, 'lang_en')),
                  secondary: const Icon(Icons.language),
                ),
                RadioListTile<String?>(
                  value: 'ar',
                  groupValue: code,
                  onChanged: (_) => AppSettings.locale.value = const Locale('ar'),
                  title: Text(S.t(context, 'lang_ar')),
                  secondary: const Icon(Icons.g_translate),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
