class AiConfig {
  final String baseUrl;
  final String model;

  AiConfig({
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-4',
  });

  AiConfig copyWith({
    String? baseUrl,
    String? model,
  }) {
    return AiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'model': model,
      };

  factory AiConfig.fromJson(Map<String, dynamic> json) => AiConfig(
        baseUrl: json['baseUrl'] as String? ?? 'https://api.openai.com/v1',
        model: json['model'] as String? ?? 'gpt-4',
      );
}
