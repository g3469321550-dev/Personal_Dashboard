class ScheduleItem {
  final String id;
  final String title;
  final String? note;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final bool isAllDay;
  final SchedulePriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? goalId;
  final String? goalRequirementId;
  final RecurrenceRule? recurrence;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleItem({
    required this.id,
    required this.title,
    this.note,
    required this.date,
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.priority = SchedulePriority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.goalId,
    this.goalRequirementId,
    this.recurrence,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ScheduleItem copyWith({
    String? title,
    String? note,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isAllDay,
    SchedulePriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    String? goalId,
    String? goalRequirementId,
    RecurrenceRule? recurrence,
  }) {
    return ScheduleItem(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: isCompleted == true ? (completedAt ?? DateTime.now()) : null,
      goalId: goalId ?? this.goalId,
      goalRequirementId: goalRequirementId ?? this.goalRequirementId,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'isAllDay': isAllDay,
        'priority': priority.name,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'goalId': goalId,
        'goalRequirementId': goalRequirementId,
        'recurrence': recurrence?.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id'] as String,
        title: json['title'] as String,
        note: json['note'] as String?,
        date: DateTime.parse(json['date'] as String),
        startTime: json['startTime'] as String?,
        endTime: json['endTime'] as String?,
        isAllDay: json['isAllDay'] as bool? ?? false,
        priority: SchedulePriority.values.firstWhere((e) => e.name == json['priority'],
            orElse: () => SchedulePriority.medium),
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        goalId: json['goalId'] as String?,
        goalRequirementId: json['goalRequirementId'] as String?,
        recurrence: json['recurrence'] != null
            ? RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class RecurrenceRule {
  final RecurrenceType type;
  final int interval;
  final DateTime? endDate;
  final List<int>? weekDays;
  final int? monthDay;

  RecurrenceRule({
    required this.type,
    this.interval = 1,
    this.endDate,
    this.weekDays,
    this.monthDay,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'interval': interval,
        'endDate': endDate?.toIso8601String(),
        'weekDays': weekDays,
        'monthDay': monthDay,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => RecurrenceRule(
        type: RecurrenceType.values.firstWhere((e) => e.name == json['type'],
            orElse: () => RecurrenceType.daily),
        interval: json['interval'] as int? ?? 1,
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        weekDays: (json['weekDays'] as List<dynamic>?)?.cast<int>(),
        monthDay: json['monthDay'] as int?,
      );
}

enum SchedulePriority { high, medium, low }
enum RecurrenceType { daily, weekly, monthly, yearly }
