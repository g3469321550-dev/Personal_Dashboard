class AiCharacter {
  final String id;
  final String name;
  final String? avatarPath;
  final String systemPrompt;
  final String? greeting;
  final CharacterPersonality personality;
  final String? modelOverride;
  final String? baseUrlOverride;
  final String? apiKeyOverride;
  final bool supportsVision;
  final DateTime createdAt;

  AiCharacter({
    required this.id,
    required this.name,
    this.avatarPath,
    required this.systemPrompt,
    this.greeting,
    this.personality = CharacterPersonality.neutral,
    this.modelOverride,
    this.baseUrlOverride,
    this.apiKeyOverride,
    this.supportsVision = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get personalityPrefix {
    switch (personality) {
      case CharacterPersonality.strict:
        return '[风格：严格] 你说话直接、不留情面，强调纪律和执行力。不使用多余的客套话，直指问题核心。';
      case CharacterPersonality.gentle:
        return '[风格：温柔] 你说话温暖、以鼓励为主，注重情感支持。用亲切的语气回应用户。';
      case CharacterPersonality.neutral:
        return '[风格：中性] 你说话客观理性，不偏向严格或温柔，注重事实和逻辑。';
    }
  }

  String get effectiveSystemPrompt => '$personalityPrefix\n\n$systemPrompt';

  AiCharacter copyWith({
    String? name,
    String? avatarPath,
    String? systemPrompt,
    String? greeting,
    CharacterPersonality? personality,
    String? modelOverride,
    String? baseUrlOverride,
    String? apiKeyOverride,
    bool? supportsVision,
  }) {
    return AiCharacter(
      id: id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      greeting: greeting ?? this.greeting,
      personality: personality ?? this.personality,
      modelOverride: modelOverride ?? this.modelOverride,
      baseUrlOverride: baseUrlOverride ?? this.baseUrlOverride,
      apiKeyOverride: apiKeyOverride ?? this.apiKeyOverride,
      supportsVision: supportsVision ?? this.supportsVision,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarPath': avatarPath,
        'systemPrompt': systemPrompt,
        'greeting': greeting,
        'personality': personality.name,
        'modelOverride': modelOverride,
        'baseUrlOverride': baseUrlOverride,
        'apiKeyOverride': apiKeyOverride,
        'supportsVision': supportsVision,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AiCharacter.fromJson(Map<String, dynamic> json) => AiCharacter(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarPath: json['avatarPath'] as String?,
        systemPrompt: json['systemPrompt'] as String,
        greeting: json['greeting'] as String?,
        personality: CharacterPersonality.values.firstWhere(
            (e) => e.name == json['personality'],
            orElse: () => CharacterPersonality.neutral),
        modelOverride: json['modelOverride'] as String?,
        baseUrlOverride: json['baseUrlOverride'] as String?,
        apiKeyOverride: json['apiKeyOverride'] as String?,
        supportsVision: json['supportsVision'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  factory AiCharacter.fromJsonImport(Map<String, dynamic> json) => AiCharacter(
        id: '',
        name: json['name'] as String,
        avatarPath: json['avatar'] as String?,
        systemPrompt: json['system_prompt'] as String? ?? '',
        greeting: json['greeting'] as String?,
        personality: CharacterPersonality.values.firstWhere(
            (e) => e.name == json['personality'],
            orElse: () => CharacterPersonality.neutral),
        supportsVision: json['supports_vision'] as bool? ?? false,
      );
}

enum CharacterPersonality { strict, gentle, neutral }
