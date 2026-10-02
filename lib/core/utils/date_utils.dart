import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static DateTime startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String formatShort(DateTime d) =>
      DateFormat.yMMMd().format(d);

  static String formatFull(DateTime d) =>
      DateFormat('EEEE, d MMMM yyyy').format(d);

  static String formatMonthYear(DateTime d) =>
      DateFormat('MMMM yyyy').format(d);

  static DateTime firstDayOfMonth(DateTime d) =>
      DateTime(d.year, d.month, 1);

  static DateTime lastDayOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0);

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;
}