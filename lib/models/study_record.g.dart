// GENERATED FILE — manually written adapter for Hive.
// Do not delete. Provides serialization for StudyRecord.

part of 'study_record.dart';

class StudyRecordAdapter extends TypeAdapter<StudyRecord> {
  @override
  final int typeId = 0;

  @override
  StudyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyRecord(
      id: fields[0] as String,
      subject: fields[1] as String,
      topic: fields[2] as String,
      date: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      notes: (fields[5] as String?) ?? '',
      status: (fields[6] as String?) ?? 'completed',
      tags: ((fields[7] as List?) ?? const <dynamic>[]).cast<String>(),
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StudyRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.topic)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }
}