class FocusSession {
  final String id;
  final String categoryId;
  final String categoryName;
  final DateTime startTime;
  final DateTime endTime;
  final Duration plannedDuration;
  final Duration actualDuration;
  final FocusSessionStatus status;
  final DateTime createdAt;

  FocusSession({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.startTime,
    required this.endTime,
    required this.plannedDuration,
    required this.actualDuration,
    this.status = FocusSessionStatus.completed,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'plannedDurationMs': plannedDuration.inMilliseconds,
        'actualDurationMs': actualDuration.inMilliseconds,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        plannedDuration: Duration(milliseconds: json['plannedDurationMs'] as int),
        actualDuration: Duration(milliseconds: json['actualDurationMs'] as int),
        status: FocusSessionStatus.values.firstWhere((e) => e.name == json['status'],
            orElse: () => FocusSessionStatus.completed),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  FocusSession copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    DateTime? startTime,
    DateTime? endTime,
    Duration? plannedDuration,
    Duration? actualDuration,
    FocusSessionStatus? status,
    DateTime? createdAt,
  }) {
    return FocusSession(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FocusCategory {
  final String id;
  final String name;
  final FocusCategoryType type;
  final String? goalId;
  final String? colorHex;

  FocusCategory({
    required this.id,
    required this.name,
    this.type = FocusCategoryType.custom,
    this.goalId,
    this.colorHex,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'goalId': goalId,
        'colorHex': colorHex,
      };

  factory FocusCategory.fromJson(Map<String, dynamic> json) => FocusCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        type: FocusCategoryType.values.firstWhere((e) => e.name == json['type'],
            orElse: () => FocusCategoryType.custom),
        goalId: json['goalId'] as String?,
        colorHex: json['colorHex'] as String?,
      );
}

enum FocusSessionStatus { completed, interrupted, paused }
enum FocusCategoryType { goal, custom }
