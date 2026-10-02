import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/duration_utils.dart';
import '../../localization/app_localizations.dart';
import '../../providers/goal_provider.dart';
import '../../providers/study_provider.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final study = context.watch<StudyProvider>();
    final goal = context.watch<GoalProvider>();

    final monthMinutes = study.monthMinutes;
    final targetHours = goal.targetHours;
    final targetMinutes = targetHours * 60;
    final progress = targetMinutes > 0
        ? (monthMinutes / targetMinutes).clamp(0.0, 1.0)
        : 0.0;
    final remainingMinutes =
        (targetMinutes - monthMinutes).clamp(0, targetMinutes);
    final percent = (progress * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.goals),
        actions: [
          IconButton(
            tooltip: l10n.editGoal,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEditGoal(context, targetHours),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (targetHours <= 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 48,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noGoalSet,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.setAGoalToTrack,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _openEditGoal(context, 0),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.setGoal),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentProgress,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor:
                                    scheme.surfaceContainerHighest,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$percent%',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                                ),
                                Text(
                                  l10n.completed,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ProgressRow(
                      label: l10n.completed,
                      value:
                          AppDurationUtils.formatHours(monthMinutes),
                    ),
                    const SizedBox(height: 8),
                    _ProgressRow(
                      label: l10n.monthlyGoal,
                      value: '${targetHours}h',
                    ),
                    const SizedBox(height: 8),
                    _ProgressRow(
                      label: l10n.remaining,
                      value: AppDurationUtils.formatHours(
                        remainingMinutes,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
                title: Text(l10n.dayStreak),
                subtitle: Text('${study.currentStreak} ${l10n.days}'),
                trailing: Text(
                  '${study.longestStreak}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openEditGoal(BuildContext context, int currentHours) async {
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
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProgressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}