class SleepRecord {
  final String id;
  final DateTime date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final Duration totalDuration;
  final Duration deepSleep;
  final Duration lightSleep;
  final Duration remSleep;
  final Duration awake;
  final int qualityScore;
  final DataSource source;

  SleepRecord({
    required this.id,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.totalDuration,
    this.deepSleep = Duration.zero,
    this.lightSleep = Duration.zero,
    this.remSleep = Duration.zero,
    this.awake = Duration.zero,
    this.qualityScore = 0,
    this.source = DataSource.manual,
  });

  SleepRecord copyWith({
    DateTime? date,
    DateTime? bedtime,
    DateTime? wakeTime,
    Duration? totalDuration,
    Duration? deepSleep,
    Duration? lightSleep,
    Duration? remSleep,
    Duration? awake,
    int? qualityScore,
    DataSource? source,
  }) {
    return SleepRecord(
      id: id,
      date: date ?? this.date,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      totalDuration: totalDuration ?? this.totalDuration,
      deepSleep: deepSleep ?? this.deepSleep,
      lightSleep: lightSleep ?? this.lightSleep,
      remSleep: remSleep ?? this.remSleep,
      awake: awake ?? this.awake,
      qualityScore: qualityScore ?? this.qualityScore,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'bedtime': bedtime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'totalDurationMs': totalDuration.inMilliseconds,
        'deepSleepMs': deepSleep.inMilliseconds,
        'lightSleepMs': lightSleep.inMilliseconds,
        'remSleepMs': remSleep.inMilliseconds,
        'awakeMs': awake.inMilliseconds,
        'qualityScore': qualityScore,
        'source': source.name,
      };

  factory SleepRecord.fromJson(Map<String, dynamic> json) => SleepRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        bedtime: DateTime.parse(json['bedtime'] as String),
        wakeTime: DateTime.parse(json['wakeTime'] as String),
        totalDuration: Duration(milliseconds: json['totalDurationMs'] as int),
        deepSleep: Duration(milliseconds: json['deepSleepMs'] as int? ?? 0),
        lightSleep: Duration(milliseconds: json['lightSleepMs'] as int? ?? 0),
        remSleep: Duration(milliseconds: json['remSleepMs'] as int? ?? 0),
        awake: Duration(milliseconds: json['awakeMs'] as int? ?? 0),
        qualityScore: json['qualityScore'] as int? ?? 0,
        source: DataSource.values.firstWhere(
            (e) => e.name == json['source'],
            orElse: () => DataSource.manual),
      );
}

enum ExerciseType {
  running,
  walking,
  cycling,
  swimming,
  strength,
  yoga,
  basketball,
  football,
  other,
}

enum DataSource { manual, band }
