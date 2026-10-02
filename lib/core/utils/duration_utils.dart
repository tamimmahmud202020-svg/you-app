class AppDurationUtils {
  AppDurationUtils._();

  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String formatHours(int minutes) {
    if (minutes <= 0) return '0h';
    final hours = minutes / 60;
    if (hours >= 10) return '${hours.toStringAsFixed(0)}h';
    return '${hours.toStringAsFixed(1)}h';
  }
}