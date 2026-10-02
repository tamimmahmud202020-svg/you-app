class Validators {
  Validators._();

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final n = int.tryParse(value);
    if (n == null) return '$fieldName must be a number';
    if (n < 0) return '$fieldName cannot be negative';
    return null;
  }

  static String? duration(String? hours, String? minutes) {
    final h = int.tryParse((hours ?? '').trim()) ?? 0;
    final m = int.tryParse((minutes ?? '').trim()) ?? 0;
    if (h < 0 || m < 0) return 'Duration cannot be negative';
    if (m >= 60) return 'Minutes must be less than 60';
    if (h == 0 && m == 0) return 'Duration must be greater than 0';
    return null;
  }
}