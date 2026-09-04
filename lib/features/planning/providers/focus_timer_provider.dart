import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/hive_init.dart';
import '../models/focus_session.dart';

const _uuid = Uuid();

enum TimerState { idle, running, paused }

class FocusTimerState {
  final TimerState timerState;
  final Duration remaining;
  final Duration elapsed;
  final FocusCategory? selectedCategory;
  final Duration plannedDuration;
  final List<FocusCategory> categories;
  final List<FocusSession> sessions;

  const FocusTimerState({
    this.timerState = TimerState.idle,
    this.remaining = Duration.zero,
    this.elapsed = Duration.zero,
    this.selectedCategory,
    this.plannedDuration = const Duration(minutes: 25),
    this.categories = const [],
    this.sessions = const [],
  });

  FocusTimerState copyWith({
    TimerState? timerState,
    Duration? remaining,
    Duration? elapsed,
    FocusCategory? selectedCategory,
    Duration? plannedDuration,
    List<FocusCategory>? categories,
    List<FocusSession>? sessions,
  }) {
    return FocusTimerState(
      timerState: timerState ?? this.timerState,
      remaining: remaining ?? this.remaining,
      elapsed: elapsed ?? this.elapsed,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      categories: categories ?? this.categories,
      sessions: sessions ?? this.sessions,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _timer;

  FocusTimerNotifier() : super(const FocusTimerState()) {
    _loadCategories();
    _loadSessions();
  }

  void _loadCategories() {
    final box = focusCategoriesBox;
    final cats = box.values
        .map((e) => FocusCategory.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))))
        .toList();
    state = state.copyWith(categories: cats);
  }

  void _loadSessions() {
    try {
      final box = focusSessionsBox;
      final sessions = box.values
          .map((e) => FocusSession.fromJson(
              Map<String, dynamic>.from(jsonDecode(e as String))))
          .toList();
      state = state.copyWith(sessions: sessions);
    } catch (e) {
      print('[FocusTimerProvider] loadSessions error: $e');
    }
  }

  void selectCategory(FocusCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setPlannedDuration(Duration duration) {
    state = state.copyWith(
      plannedDuration: duration,
      remaining: duration,
    );
  }

  void start() {
    if (state.timerState == TimerState.running) return;
    final category = state.selectedCategory;
    if (category == null) return;

    final remaining = state.remaining == Duration.zero
        ? state.plannedDuration
        : state.remaining;

    state = state.copyWith(
      timerState: TimerState.running,
      remaining: remaining,
      plannedDuration: state.plannedDuration == Duration.zero
          ? remaining
          : state.plannedDuration,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remaining <= const Duration(seconds: 1)) {
        _complete();
      } else {
        state = state.copyWith(
          remaining: state.remaining - const Duration(seconds: 1),
          elapsed: state.elapsed + const Duration(seconds: 1),
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(timerState: TimerState.paused);
  }

  void resume() {
    start();
  }

  void stop() {
    _timer?.cancel();
    if (state.elapsed > Duration.zero) {
      _saveSession(FocusSessionStatus.interrupted);
    }
    _reset();
  }

  void _complete() {
    _timer?.cancel();
    _saveSession(FocusSessionStatus.completed);
    _reset();
  }

  void _reset() {
    state = FocusTimerState(
      selectedCategory: state.selectedCategory,
      plannedDuration: state.plannedDuration,
      categories: state.categories,
      sessions: state.sessions,
    );
  }

  void _saveSession(FocusSessionStatus status) {
    final category = state.selectedCategory;
    if (category == null) return;

    final session = FocusSession(
      id: _uuid.v4(),
      categoryId: category.id,
      categoryName: category.name,
      startTime: DateTime.now().subtract(state.elapsed),
      endTime: DateTime.now(),
      plannedDuration: state.plannedDuration,
      actualDuration: state.elapsed,
      status: status,
    );

    final box = focusSessionsBox;
    box.put(session.id, jsonEncode(session.toJson()));
    state = state.copyWith(sessions: [...state.sessions, session]);
  }

  List<FocusCategory> getCategories() => state.categories;

  void addCategory(FocusCategory category) {
    final box = focusCategoriesBox;
    box.put(category.id, jsonEncode(category.toJson()));
    state = state.copyWith(categories: [...state.categories, category]);
  }

  void deleteCategory(String id) {
    final box = focusCategoriesBox;
    box.delete(id);
    state = state.copyWith(
      categories: state.categories.where((c) => c.id != id).toList(),
    );
  }

  List<FocusSession> getSessions({DateTime? date}) {
    if (date == null) return state.sessions;
    return state.sessions
        .where((s) =>
            s.startTime.year == date.year &&
            s.startTime.month == date.month &&
            s.startTime.day == date.day)
        .toList();
  }

  void deleteSession(String id) {
    final box = focusSessionsBox;
    box.delete(id);
    state = state.copyWith(
      sessions: state.sessions.where((s) => s.id != id).toList(),
    );
  }

  void updateSession(String id, FocusSession updated) {
    final box = focusSessionsBox;
    box.put(id, jsonEncode(updated.toJson()));
    state = state.copyWith(
      sessions: [
        for (final s in state.sessions)
          if (s.id == id) updated else s,
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier();
});
