import 'package:hive/hive.dart';

part 'monthly_goal.g.dart';

@HiveType(typeId: 1)
class MonthlyGoal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int year;

  @HiveField(2)
  final int month;

  @HiveField(3)
  final int targetHours;

  @HiveField(4)
  final DateTime createdAt;

  MonthlyGoal({
    required this.id,
    required this.year,
    required this.month,
    required this.targetHours,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MonthlyGoal copyWith({
    String? id,
    int? year,
    int? month,
    int? targetHours,
    DateTime? createdAt,
  }) {
    return MonthlyGoal(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      targetHours: targetHours ?? this.targetHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get monthKey =>
      '$year-${month.toString().padLeft(2, '0')}';
}