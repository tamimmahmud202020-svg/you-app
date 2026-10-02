import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'localization/app_localizations.dart';
import 'providers/goal_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/study_provider.dart';
import 'screens/main_navigation.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await DatabaseService.init();
  runApp(const YouApp());
}

class YouApp extends StatelessWidget {
  const YouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider()..load(),
        ),
        ChangeNotifierProvider<StudyProvider>(
          create: (_) => StudyProvider()..load(),
        ),
        ChangeNotifierProvider<GoalProvider>(
          create: (_) => GoalProvider()..load(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'YOU',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}