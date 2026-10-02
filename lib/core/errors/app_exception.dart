class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, {this.details});

  @override
  String toString() =>
      details == null ? message : '$message ($details)';
}