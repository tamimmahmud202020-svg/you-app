import 'package:hive/hive.dart';

import '../core/utils/date_utils.dart';
import '../models/study_record.dart';
import '../services/database_service.dart';

class StudyRepository {
  Box<StudyRecord> get _box => DatabaseService.studyBox;

  List<StudyRecord> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<StudyRecord> getByDate(DateTime date) {
    return _box.values
        .where((r) => AppDateUtils.isSameDay(r.date, date))
        .toList();
  }

  Future<void> add(StudyRecord record) async {
    await _box.put(record.id, record);
  }

  Future<void> update(StudyRecord record) async {
    await _box.put(
      record.id,
      record.copyWith(updatedAt: DateTime.now()),
    );
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}