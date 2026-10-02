import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/monthly_goal.dart';
import '../services/database_service.dart';

class GoalProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  MonthlyGoal? _current;
  bool _loading = true;

  MonthlyGoal? get current => _current;
  bool get isLoading => _loading;
  bool get hasGoal => _current != null;
  int get targetHours => _current?.targetHours ?? 0;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final now = DateTime.now();
    _current = _findFor(now.year, now.month);
    _loading = false;
    notifyListeners();
  }

  MonthlyGoal? _findFor(int year, int month) {
    for (final goal in DatabaseService.goalBox.values) {
      if (goal.year == year && goal.month == month) {
        return goal;
      }
    }
    return null;
  }

  Future<void> setGoal(int hours, {DateTime? forDate}) async {
    if (hours <= 0) return;
    final d = forDate ?? DateTime.now();
    final existing = _findFor(d.year, d.month);

    if (existing != null) {
      final updated = existing.copyWith(targetHours: hours);
      await DatabaseService.goalBox.put(existing.id, updated);
    } else {
      final goal = MonthlyGoal(
        id: _uuid.v4(),
        year: d.year,
        month: d.month,
        targetHours: hours,
      );
      await DatabaseService.goalBox.put(goal.id, goal);
    }
    await load();
  }

  Future<void> clearGoal() async {
    if (_current != null) {
      await DatabaseService.goalBox.delete(_current!.id);
      await load();
    }
  }
}