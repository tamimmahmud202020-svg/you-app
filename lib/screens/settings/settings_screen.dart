import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../localization/app_localizations.dart';
import '../../providers/goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_provider.dart';
import '../../services/database_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();
    final goal = context.watch<GoalProvider>();
    final current = settings.settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _SectionHeader(l10n.language),
          RadioListTile<String>(
            title: Text(l10n.english),
            value: 'en',
            groupValue: current.languageCode,
            onChanged: (v) {
              if (v != null) settings.setLanguage(v);
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.bangla),
            value: 'bn',
            groupValue: current.languageCode,
            onChanged: (v) {
              if (v != null) settings.setLanguage(v);
            },
          ),
          const Divider(height: 1),

          _SectionHeader(l10n.theme),
          RadioListTile<String>(
            title: Text(l10n.themeSystem),
            value: 'system',
            groupValue: current.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.themeLight),
            value: 'light',
            groupValue: current.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.themeDark),
            value: 'dark',
            groupValue: current.themeMode,
            onChanged: (v) {
              if (v != null) settings.setThemeMode(v);
            },
          ),
          const Divider(height: 1),

          _SectionHeader(l10n.monthlyGoal),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text(l10n.setMonthlyGoal),
            subtitle: Text(
              goal.targetHours > 0
                  ? '${goal.targetHours} ${l10n.hours}'
                  : l10n.goalNotSet,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editGoal(context, goal.targetHours),
          ),
          const Divider(height: 1),

          _SectionHeader(l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appName),
            subtitle: Text(l10n.appTagline),
          ),
          ListTile(
            leading: const Icon(Icons.numbers),
            title: Text(l10n.version),
            subtitle: const Text(AppConstants.appVersion),
          ),
          const Divider(height: 1),

          _SectionHeader(l10n.data),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(l10n.clearAllData),
            subtitle: Text(l10n.clearAllDataConfirmMessage),
            onTap: () => _confirmClearAll(context),
          ),
        ],
      ),
    );
  }

  Future<void> _editGoal(BuildContext context, int currentHours) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: currentHours > 0 ? '$currentHours' : '',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.setMonthlyGoal),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.goalHours,
              suffixText: l10n.hours,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(l10n.saveGoal),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result != null && result > 0 && context.mounted) {
      await context.read<GoalProvider>().setGoal(result);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.clearAllDataConfirmTitle),
          content: Text(l10n.clearAllDataConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await DatabaseService.clearAll();
      if (!context.mounted) return;
      await context.read<StudyProvider>().load();
      if (!context.mounted) return;
      await context.read<GoalProvider>().load();
      if (!context.mounted) return;
      await context.read<SettingsProvider>().resetToDefaults();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dataCleared)),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}