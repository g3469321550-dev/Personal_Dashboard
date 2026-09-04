class Goal {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyRequirement> dailyRequirements;
  final GoalStatus status;
  final DateTime? reminderDate;
  final String? colorTag;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    List<DailyRequirement>? dailyRequirements,
    this.status = GoalStatus.active,
    this.reminderDate,
    this.colorTag,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : dailyRequirements = dailyRequirements ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Goal copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    DateTime? startDate,
    DateTime? endDate,
    List<DailyRequirement>? dailyRequirements,
    GoalStatus? status,
    DateTime? reminderDate,
    bool clearReminderDate = false,
    String? colorTag,
    bool clearColorTag = false,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dailyRequirements: dailyRequirements ?? this.dailyRequirements,
      status: status ?? this.status,
      reminderDate: clearReminderDate ? null : (reminderDate ?? this.reminderDate),
      colorTag: clearColorTag ? null : (colorTag ?? this.colorTag),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'dailyRequirements': dailyRequirements.map((e) => e.toJson()).toList(),
        'status': status.name,
        'reminderDate': reminderDate?.toIso8601String(),
        'colorTag': colorTag,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        dailyRequirements: (json['dailyRequirements'] as List<dynamic>?)
                ?.map((e) => DailyRequirement.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        status: GoalStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => GoalStatus.active),
        reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate'] as String) : null,
        colorTag: json['colorTag'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class DailyRequirement {
  final String id;
  final String content;
  final String? unit;
  final double? targetValue;
  final bool isQuantitative;
  final Map<String, bool> completionHistory;
  final DateTime createdAt;

  DailyRequirement({
    required this.id,
    required this.content,
    this.unit,
    this.targetValue,
    this.isQuantitative = false,
    Map<String, bool>? completionHistory,
    DateTime? createdAt,
  })  : completionHistory = completionHistory ?? {},
        createdAt = createdAt ?? DateTime.now();

  bool isCompletedOn(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    return completionHistory[key] ?? false;
  }

  DailyRequirement copyWith({
    String? content,
    String? unit,
    double? targetValue,
    bool? isQuantitative,
    Map<String, bool>? completionHistory,
  }) {
    return DailyRequirement(
      id: id,
      content: content ?? this.content,
      unit: unit ?? this.unit,
      targetValue: targetValue ?? this.targetValue,
      isQuantitative: isQuantitative ?? this.isQuantitative,
      completionHistory: completionHistory ?? this.completionHistory,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'unit': unit,
        'targetValue': targetValue,
        'isQuantitative': isQuantitative,
        'completionHistory': completionHistory,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DailyRequirement.fromJson(Map<String, dynamic> json) => DailyRequirement(
        id: json['id'] as String,
        content: json['content'] as String,
        unit: json['unit'] as String?,
        targetValue: (json['targetValue'] as num?)?.toDouble(),
        isQuantitative: json['isQuantitative'] as bool? ?? false,
        completionHistory: (json['completionHistory'] as Map<String, dynamic>?)?.cast<String, bool>() ?? {},
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

enum GoalStatus { active, completed, archived }
