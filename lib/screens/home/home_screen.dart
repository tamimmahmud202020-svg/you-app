import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/duration_utils.dart';
import '../../localization/app_localizations.dart';
import '../../models/study_record.dart';
import '../../providers/goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/study_card.dart';
import '../study/add_study_screen.dart';
import '../study/study_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final study = context.watch<StudyProvider>();
    final goal = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();

    final now = DateTime.now();
    final greeting = _greeting(l10n, now);
    final recent = study.allRecords.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<StudyProvider>().load();
            await context.read<GoalProvider>().load();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(
                '$greeting 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppDateUtils.formatFull(now),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 104,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatCard(
                        label: l10n.todaysTime,
                        value: AppDurationUtils.formatMinutes(
                          study.todayMinutes,
                        ),
                        icon: Icons.schedule,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: l10n.todaysSessions,
                        value: '${study.todaySessions}',
                        icon: Icons.menu_book,
                        color: scheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: l10n.dayStreak,
                        value: '${study.currentStreak}',
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _MonthlyGoalCard(
                monthMinutes: study.monthMinutes,
                goalHours: goal.targetHours,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    l10n.recentStudies,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (study.allRecords.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const StudyHistoryScreen(),
                          ),
                        );
                      },
                      child: Text(l10n.seeAll),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (recent.isEmpty)
                _EmptyHomeCard(
                  onAdd: () => _openAdd(context),
                )
              else
                ...recent.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StudyCard(
                      record: r,
                      languageCode: settings.settings.languageCode,
                      onTap: () => _openEdit(context, r),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addStudy),
      ),
    );
  }

  String _greeting(AppLocalizations l10n, DateTime now) {
    if (now.hour < 12) return l10n.greetingMorning;
    if (now.hour < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }

  void _openAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddStudyScreen()),
    );
  }

  void _openEdit(BuildContext context, StudyRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddStudyScreen(existing: record),
      ),
    );
  }
}

class _MonthlyGoalCard extends StatelessWidget {
  final int monthMinutes;
  final int goalHours;

  const _MonthlyGoalCard({
    required this.monthMinutes,
    required this.goalHours,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final targetMinutes = goalHours * 60;
    final hasGoal = goalHours > 0;
    final progress = hasGoal
        ? (monthMinutes / targetMinutes).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined,
                    size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.monthlyGoal,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (hasGoal)
                  Text(
                    '$percent%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    l10n.goalNotSet,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasGoal
                  ? '${AppDurationUtils.formatHours(monthMinutes)} ${l10n.ofGoal} ${goalHours}h'
                  : AppDurationUtils.formatHours(monthMinutes),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyHomeCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined,
                size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              l10n.noRecordsYet,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.addFirstStudy,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addStudy),
            ),
          ],
        ),
      ),
    );
  }
}