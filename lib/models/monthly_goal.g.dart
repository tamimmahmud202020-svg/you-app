// GENERATED FILE — manually written adapter for Hive.

part of 'monthly_goal.dart';

class MonthlyGoalAdapter extends TypeAdapter<MonthlyGoal> {
  @override
  final int typeId = 1;

  @override
  MonthlyGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyGoal(
      id: fields[0] as String,
      year: fields[1] as int,
      month: fields[2] as int,
      targetHours: fields[3] as int,
      createdAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyGoal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.targetHours)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}