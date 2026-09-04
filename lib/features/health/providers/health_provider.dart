import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/hive_init.dart';
import '../models/sleep_record.dart';
import '../models/exercise_record.dart';

class HealthNotifier extends StateNotifier<HealthState> {
  HealthNotifier() : super(const HealthState()) {
    _load();
  }

  void _load() {
    final sleepBox = sleepRecordsBox;
    final exerciseBox = exerciseRecordsBox;

    final sleeps = <SleepRecord>[];
    for (final e in sleepBox.values) {
      try {
        sleeps.add(SleepRecord.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))));
      } catch (e) {
        print('[HealthProvider] Failed to load sleep record: $e');
      }
    }

    final exercises = <ExerciseRecord>[];
    for (final e in exerciseBox.values) {
      try {
        exercises.add(ExerciseRecord.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))));
      } catch (e) {
        print('[HealthProvider] Failed to load exercise record: $e');
      }
    }

    state = HealthState(sleepRecords: sleeps, exerciseRecords: exercises);
  }

  void addSleepRecord(SleepRecord record) {
    final box = sleepRecordsBox;
    box.put(record.id, jsonEncode(record.toJson()));
    state = state.copyWith(
      sleepRecords: [...state.sleepRecords, record],
    );
  }

  void addExerciseRecord(ExerciseRecord record) {
    final box = exerciseRecordsBox;
    box.put(record.id, jsonEncode(record.toJson()));
    state = state.copyWith(
      exerciseRecords: [...state.exerciseRecords, record],
    );
  }

  void deleteSleepRecord(String id) {
    sleepRecordsBox.delete(id);
    state = state.copyWith(
      sleepRecords: state.sleepRecords.where((r) => r.id != id).toList(),
    );
  }

  void deleteExerciseRecord(String id) {
    exerciseRecordsBox.delete(id);
    state = state.copyWith(
      exerciseRecords:
          state.exerciseRecords.where((r) => r.id != id).toList(),
    );
  }
}

class HealthState {
  final List<SleepRecord> sleepRecords;
  final List<ExerciseRecord> exerciseRecords;

  const HealthState({
    this.sleepRecords = const [],
    this.exerciseRecords = const [],
  });

  HealthState copyWith({
    List<SleepRecord>? sleepRecords,
    List<ExerciseRecord>? exerciseRecords,
  }) {
    return HealthState(
      sleepRecords: sleepRecords ?? this.sleepRecords,
      exerciseRecords: exerciseRecords ?? this.exerciseRecords,
    );
  }
}

final healthProvider =
    StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  return HealthNotifier();
});
