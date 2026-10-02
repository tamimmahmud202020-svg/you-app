import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../localization/app_localizations.dart';
import '../../models/study_record.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/study_card.dart';
import 'add_study_screen.dart';

class StudyHistoryScreen extends StatefulWidget {
  const StudyHistoryScreen({super.key});

  @override
  State<StudyHistoryScreen> createState() => _StudyHistoryScreenState();
}

class _StudyHistoryScreenState extends State<StudyHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final study = context.watch<StudyProvider>();
    final settings = context.watch<SettingsProvider>();
    final records = study.visibleRecords;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStudy),
        actions: [
          IconButton(
            tooltip: l10n.clearFilters,
            onPressed: () {
              _searchController.clear();
              study.clearFilters();
            },
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: study.setQuery,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          study.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip(
                  context,
                  label: l10n.filterAll,
                  selected: study.filter == StudyFilter.all,
                  onTap: () => study.setFilter(StudyFilter.all),
                ),
                _filterChip(
                  context,
                  label: l10n.filterToday,
                  selected: study.filter == StudyFilter.today,
                  onTap: () => study.setFilter(StudyFilter.today),
                ),
                _filterChip(
                  context,
                  label: l10n.filterThisWeek,
                  selected: study.filter == StudyFilter.thisWeek,
                  onTap: () => study.setFilter(StudyFilter.thisWeek),
                ),
                _filterChip(
                  context,
                  label: l10n.filterThisMonth,
                  selected: study.filter == StudyFilter.thisMonth,
                  onTap: () => study.setFilter(StudyFilter.thisMonth),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Text(
                  '${records.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<StudySort>(
                  initialValue: study.sort,
                  onSelected: study.setSort,
                  itemBuilder: (_) => [
                    PopupMenuItem<StudySort>(
                      value: StudySort.newest,
                      child: Text(l10n.sortNewest),
                    ),
                    PopupMenuItem<StudySort>(
                      value: StudySort.oldest,
                      child: Text(l10n.sortOldest),
                    ),
                    PopupMenuItem<StudySort>(
                      value: StudySort.longest,
                      child: Text(l10n.sortLongest),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.sortBy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: study.isEmpty
                        ? l10n.noRecordsYet
                        : l10n.noResults,
                    subtitle: study.isEmpty
                        ? l10n.addFirstStudy
                        : l10n.tryDifferentFilters,
                    actionLabel:
                        study.isEmpty ? l10n.addStudy : null,
                    onAction: study.isEmpty
                        ? () => _openAdd(context)
                        : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: records.length,
                    itemBuilder: (_, index) {
                      final record = records[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StudyCard(
                          record: record,
                          languageCode:
                              settings.settings.languageCode,
                          onTap: () => _openEdit(context, record),
                          onEdit: () => _openEdit(context, record),
                          onDuplicate: () =>
                              _duplicate(context, record),
                          onDelete: () =>
                              _confirmDelete(context, record),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
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

  Future<void> _duplicate(
    BuildContext context,
    StudyRecord record,
  ) async {
    final l10n = AppLocalizations.of(context);
    await context.read<StudyProvider>().duplicateRecord(record);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.recordDuplicated)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    StudyRecord record,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteStudyConfirmTitle),
          content: Text(l10n.deleteStudyConfirmMessage),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<StudyProvider>().deleteRecord(record.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.recordDeleted)),
      );
    }
  }
}