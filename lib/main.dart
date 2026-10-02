class AiConfig {
  final String provider;
  final String model;
  final bool enabled;
  final String? apiKey;

  const AiConfig({
    this.provider = 'gemini',
    this.model = 'gemini-1.5-flash',
    this.enabled = false,
    this.apiKey,
  });

  bool get isReady => enabled && apiKey != null && apiKey!.isNotEmpty;

  AiConfig copyWith({
    String? provider,
    String? model,
    bool? enabled,
    String? apiKey,
  }) {
    return AiConfig(
      provider: provider ?? this.provider,
      model: model ?? this.model,
      enabled: enabled ?? this.enabled,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  /// Available models for Gemini provider.
  static const List<String> geminiModels = [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash-exp',
  ];

  /// Available providers. Only Gemini is free for now.
  static const List<String> providers = [
    'gemini',
  ];

  @override
  String toString() =>
      'AiConfig(provider: $provider, model: $model, enabled: $enabled, hasKey: ${apiKey?.isNotEmpty ?? false})';
}