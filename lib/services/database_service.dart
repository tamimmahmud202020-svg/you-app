import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/monthly_goal.dart';
import '../models/study_record.dart';

class DatabaseService {
  DatabaseService._();

  static const String studyBoxName = 'study_records_box_v1';
  static const String goalBoxName = 'monthly_goals_box_v1';
  static const String settingsBoxName = 'app_settings_box_v1';

  static late Box<StudyRecord> studyBox;
  static late Box<MonthlyGoal> goalBox;
  static late Box<AppSettings> settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StudyRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MonthlyGoalAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    studyBox = await Hive.openBox<StudyRecord>(studyBoxName);
    goalBox = await Hive.openBox<MonthlyGoal>(goalBoxName);
    settingsBox = await Hive.openBox<AppSettings>(settingsBoxName);
  }

  static Future<void> clearAll() async {
    await studyBox.clear();
    await goalBox.clear();
    await settingsBox.clear();
  }
}