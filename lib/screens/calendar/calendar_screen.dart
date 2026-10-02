import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/duration_utils.dart';
import '../../localization/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/study_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const List<String> _weekdaysEn = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final study = context.watch<StudyProvider>();
    final settings = context.watch<SettingsProvider>();

    final daysInMonth = AppDateUtils.daysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekday = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    ).weekday;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final selectedRecords = study.recordsForDay(_selectedDay);
    final selectedMinutes =
        selectedRecords.fold(0, (s, r) => s + r.durationMinutes);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendar)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                      1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    AppDateUtils.formatMonthYear(_focusedMonth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                      1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final label in _weekdaysEn)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Builder(
                    builder: (_) {
                      final index = row * 7 + col;
                      final dayNumber = index - leadingBlanks + 1;
                      if (dayNumber < 1 || dayNumber > daysInMonth) {
                        return const Expanded(
                          child: SizedBox(height: 44),
                        );
                      }
                      final date = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month,
                        dayNumber,
                      );
                      final hasStudy = study.studyDays.contains(date);
                      final isSelected =
                          AppDateUtils.isSameDay(date, _selectedDay);
                      final isToday =
                          AppDateUtils.isSameDay(date, DateTime.now());

                      return Expanded(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedDay = date),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 44,
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? scheme.primary
                                  : hasStudy
                                      ? scheme.primaryContainer
                                          .withOpacity(0.5)
                                      : null,
                              borderRadius: BorderRadius.circular(10),
                              border: isToday && !isSelected
                                  ? Border.all(
                                      color: scheme.primary,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        isSelected || isToday
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                    color: isSelected
                                        ? scheme.onPrimary
                                        : scheme.onSurface,
                                  ),
                                ),
                                if (hasStudy)
                                  Container(
                                    width: 4,
                                    height: 4,
                                    margin:
                                        const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? scheme.onPrimary
                                          : scheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Text(
            AppDateUtils.formatFull(_selectedDay),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedRecords.isEmpty
                ? l10n.noStudyOnDay
                : '${selectedRecords.length} ${l10n.sessions} · '
                    '${AppDurationUtils.formatMinutes(selectedMinutes)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...selectedRecords.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StudyCard(
                record: r,
                languageCode: settings.settings.languageCode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}