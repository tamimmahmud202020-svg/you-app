enum AiErrorType {
  noInternet,
  invalidApiKey,
  rateLimitExceeded,
  serverError,
  timeout,
  invalidResponse,
  notConfigured,
  unknown,
}

class AiException implements Exception {
  final AiErrorType type;
  final String message;
  final String? details;

  AiException({
    required this.type,
    required this.message,
    this.details,
  });

  factory AiException.noInternet() => AiException(
        type: AiErrorType.noInternet,
        message: 'No internet connection. Please check your network.',
      );

  factory AiException.invalidApiKey() => AiException(
        type: AiErrorType.invalidApiKey,
        message: 'Invalid API key. Please check your Gemini API key.',
      );

  factory AiException.rateLimitExceeded() => AiException(
        type: AiErrorType.rateLimitExceeded,
        message: 'Too many requests. Please wait a moment and try again.',
      );

  factory AiException.serverError(int statusCode) => AiException(
        type: AiErrorType.serverError,
        message: 'Server error ($statusCode). Try again later.',
      );

  factory AiException.timeout() => AiException(
        type: AiErrorType.timeout,
        message: 'Request timed out. Please try again.',
      );

  factory AiException.invalidResponse([String? details]) => AiException(
        type: AiErrorType.invalidResponse,
        message: 'AI returned an invalid response. Please try again.',
        details: details,
      );

  factory AiException.notConfigured() => AiException(
        type: AiErrorType.notConfigured,
        message: 'AI is not configured. Please set your API key in Settings.',
      );

  factory AiException.unknown([String? details]) => AiException(
        type: AiErrorType.unknown,
        message: 'Something went wrong. Please try again.',
        details: details,
      );

  @override
  String toString() => details == null ? message : '$message ($details)';
}