import 'sleep_record.dart';

class ExerciseRecord {
  final String id;
  final DateTime date;
  final ExerciseType type;
  final Duration duration;
  final int calories;
  final int heartRateAvg;
  final int heartRateMax;
  final double? distance;
  final DataSource source;

  ExerciseRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.duration,
    this.calories = 0,
    this.heartRateAvg = 0,
    this.heartRateMax = 0,
    this.distance,
    this.source = DataSource.manual,
  });

  ExerciseRecord copyWith({
    DateTime? date,
    ExerciseType? type,
    Duration? duration,
    int? calories,
    int? heartRateAvg,
    int? heartRateMax,
    double? distance,
    DataSource? source,
  }) {
    return ExerciseRecord(
      id: id,
      date: date ?? this.date,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      distance: distance ?? this.distance,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'type': type.name,
        'durationMs': duration.inMilliseconds,
        'calories': calories,
        'heartRateAvg': heartRateAvg,
        'heartRateMax': heartRateMax,
        'distance': distance,
        'source': source.name,
      };

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) => ExerciseRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        type: ExerciseType.values.firstWhere(
            (e) => e.name == json['type'],
            orElse: () => ExerciseType.other),
        duration: Duration(milliseconds: json['durationMs'] as int),
        calories: json['calories'] as int? ?? 0,
        heartRateAvg: json['heartRateAvg'] as int? ?? 0,
        heartRateMax: json['heartRateMax'] as int? ?? 0,
        distance: (json['distance'] as num?)?.toDouble(),
        source: DataSource.values.firstWhere(
            (e) => e.name == json['source'],
            orElse: () => DataSource.manual),
      );
}
