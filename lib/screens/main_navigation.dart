import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/app_localizations.dart';
import '../providers/study_provider.dart';
import '../widgets/loading_widget.dart';
import 'calendar/calendar_screen.dart';
import 'goals/goals_screen.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';
import 'study/study_history_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    StudyHistoryScreen(),
    CalendarScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final study = context.watch<StudyProvider>();

    if (study.isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.navStudy,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l10n.navGoals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}