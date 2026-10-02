import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/date_utils.dart';
import '../models/study_record.dart';
import '../repositories/study_repository.dart';

enum StudyFilter { all, today, thisWeek, thisMonth, subject }
enum StudySort { newest, oldest, longest }

class StudyProvider extends ChangeNotifier {
  final StudyRepository _repository = StudyRepository();
  final Uuid _uuid = const Uuid();

  List<StudyRecord> _all = <StudyRecord>[];
  bool _loading = true;
  String _query = '';
  StudyFilter _filter = StudyFilter.all;
  StudySort _sort = StudySort.newest;
  String? _subjectFilter;

  bool get isLoading => _loading;
  List<StudyRecord> get allRecords => List<StudyRecord>.unmodifiable(_all);
  String get query => _query;
  StudyFilter get filter => _filter;
  StudySort get sort => _sort;
  String? get subjectFilter => _subjectFilter;
  bool get isEmpty => _all.isEmpty;

  List<StudyRecord> get visibleRecords {
    final now = DateTime.now();
    final todayStart = AppDateUtils.startOfDay(now);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final q = _query.trim().toLowerCase();

    final result = <StudyRecord>[];
    for (final r in _all) {
      if (q.isNotEmpty) {
        final haystack = '${r.subject} ${r.topic} ${r.notes}'.toLowerCase();
        if (!haystack.contains(q)) continue;
      }

      switch (_filter) {
        case StudyFilter.today:
          if (!AppDateUtils.isSameDay(r.date, now)) continue;
          break;
        case StudyFilter.thisWeek:
          if (r.date.isBefore(weekStart)) continue;
          break;
        case StudyFilter.thisMonth:
          if (r.date.isBefore(monthStart)) continue;
          if (!r.date.isBefore(nextMonthStart)) continue;
          break;
        case StudyFilter.subject:
          if (_subjectFilter != null && r.subject != _subjectFilter) {
            continue;
          }
          break;
        case StudyFilter.all:
          break;
      }

      result.add(r);
    }

    switch (_sort) {
      case StudySort.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case StudySort.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case StudySort.longest:
        result.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
        break;
    }
    return result;
  }

  List<StudyRecord> get todayRecords {
    final now = DateTime.now();
    return _all.where((r) => AppDateUtils.isSameDay(r.date, now)).toList();
  }

  int get todayMinutes =>
      todayRecords.fold(0, (sum, r) => sum + r.durationMinutes);

  int get todaySessions => todayRecords.length;

  int get monthMinutes {
    final now = DateTime.now();
    return _all
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold(0, (sum, r) => sum + r.durationMinutes);
  }

  Set<DateTime> get studyDays => _all
      .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
      .toSet();

  int get currentStreak {
    final days = studyDays;
    if (days.isEmpty) return 0;
    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    final days = studyDays.toList()..sort();
    if (days.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  int get totalSessions => _all.length;
  int get totalMinutes =>
      _all.fold(0, (sum, r) => sum + r.durationMinutes);
  int get totalStudyDays => studyDays.length;

  List<StudyRecord> recordsForDay(DateTime day) {
    return _all
        .where((r) => AppDateUtils.isSameDay(r.date, day))
        .toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = _repository.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<StudyRecord> addRecord({
    required String subject,
    required String topic,
    required DateTime date,
    required int durationMinutes,
    String notes = '',
    String status = 'completed',
    List<String> tags = const <String>[],
  }) async {
    final record = StudyRecord(
      id: _uuid.v4(),
      subject: subject,
      topic: topic,
      date: date,
      durationMinutes: durationMinutes,
      notes: notes,
      status: status,
      tags: tags,
    );
    await _repository.add(record);
    await load();
    return record;
  }

  Future<void> updateRecord(StudyRecord record) async {
    await _repository.update(record);
    await load();
  }

  Future<void> deleteRecord(String id) async {
    await _repository.delete(id);
    await load();
  }

  Future<void> duplicateRecord(StudyRecord record) async {
    final copy = StudyRecord(
      id: _uuid.v4(),
      subject: record.subject,
      topic: record.topic,
      date: DateTime.now(),
      durationMinutes: record.durationMinutes,
      notes: record.notes,
      status: record.status,
      tags: List<String>.from(record.tags),
    );
    await _repository.add(copy);
    await load();
  }

  Future<void> clearAll() async {
    await _repository.clear();
    await load();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void setFilter(StudyFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  void setSort(StudySort value) {
    if (_sort == value) return;
    _sort = value;
    notifyListeners();
  }

  void setSubjectFilter(String? subject) {
    _subjectFilter = subject;
    _filter = subject == null ? StudyFilter.all : StudyFilter.subject;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _filter = StudyFilter.all;
    _sort = StudySort.newest;
    _subjectFilter = null;
    notifyListeners();
  }
}