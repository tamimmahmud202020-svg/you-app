import 'package:hive/hive.dart';

part 'study_record.g.dart';

@HiveType(typeId: 0)
class StudyRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String topic;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final List<String> tags;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  StudyRecord({
    required this.id,
    required this.subject,
    required this.topic,
    required this.date,
    required this.durationMinutes,
    this.notes = '',
    this.status = 'completed',
    this.tags = const <String>[],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  StudyRecord copyWith({
    String? id,
    String? subject,
    String? topic,
    DateTime? date,
    int? durationMinutes,
    String? notes,
    String? status,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyRecord(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      tags: tags ?? List<String>.from(this.tags),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'subject': subject,
        'topic': topic,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'notes': notes,
        'status': status,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StudyRecord.fromJson(Map<String, dynamic> json) {
    return StudyRecord(
      id: json['id'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
      notes: (json['notes'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'completed',
      tags: ((json['tags'] as List<dynamic>?) ?? const <dynamic>[])
          .cast<String>(),
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() =>
      'StudyRecord($subject — $topic, ${durationMinutes}min)';
}