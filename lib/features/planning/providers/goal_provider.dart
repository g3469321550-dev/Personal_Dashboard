import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/hive_init.dart';
import '../models/goal.dart';

const _uuid = Uuid();

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = goalsBox;
    print('[GoalProvider] _load: box has ${box.length} entries, keys=${box.keys.toList()}');
    final goals = <Goal>[];
    for (final e in box.values) {
      try {
        print('[GoalProvider] raw entry: ${(e as String).substring(0, e.length > 100 ? 100 : e.length)}...');
        goals.add(Goal.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))));
      } catch (e) {
        print('[GoalProvider] Failed to load goal: $e');
      }
    }
    print('[GoalProvider] _load: loaded ${goals.length} goals');
    state = goals;
  }

  void _persist() {
    final box = goalsBox;
    final currentKeys = box.keys.map((e) => e.toString()).toSet();
    final stateKeys = state.map((g) => g.id).toSet();

    for (final key in currentKeys) {
      if (!stateKeys.contains(key)) {
        box.delete(key);
      }
    }

    for (final goal in state) {
      box.put(goal.id, jsonEncode(goal.toJson()));
    }

    print('[GoalProvider] _persist: box has ${box.length} entries after sync');
  }

  void addGoal({
    required String title,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    String? colorTag,
  }) {
    print('[GoalProvider] addGoal: title=$title, colorTag=$colorTag');
    final goal = Goal(
      id: _uuid.v4(),
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      colorTag: colorTag,
    );
    state = [...state, goal];
    print('[GoalProvider] addGoal: state now has ${state.length} goals');
    _persist();
  }

  void updateGoal(String id, Goal updated) {
    state = [for (final g in state) if (g.id == id) updated else g];
    _persist();
  }

  void deleteGoal(String id) {
    state = state.where((g) => g.id != id).toList();
    _persist();
  }

  void toggleRequirementCompletion(String goalId, String reqId, DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    state = [
      for (final goal in state)
        if (goal.id == goalId)
          goal.copyWith(
            dailyRequirements: [
              for (final req in goal.dailyRequirements)
                if (req.id == reqId)
                  req.copyWith(
                    completionHistory: {
                      ...req.completionHistory,
                      key: !(req.completionHistory[key] ?? false),
                    },
                  )
                else
                  req,
            ],
          )
        else
          goal,
    ];
    _persist();
  }

  void addRequirement(String goalId, DailyRequirement requirement) {
    state = [
      for (final goal in state)
        if (goal.id == goalId)
          goal.copyWith(
            dailyRequirements: [...goal.dailyRequirements, requirement],
          )
        else
          goal,
    ];
    _persist();
  }

  void deleteRequirement(String goalId, String reqId) {
    state = [
      for (final goal in state)
        if (goal.id == goalId)
          goal.copyWith(
            dailyRequirements:
                goal.dailyRequirements.where((r) => r.id != reqId).toList(),
          )
        else
          goal,
    ];
    _persist();
  }

  void updateRequirement(String goalId, String reqId, DailyRequirement updated) {
    state = [
      for (final goal in state)
        if (goal.id == goalId)
          goal.copyWith(
            dailyRequirements: [
              for (final r in goal.dailyRequirements)
                if (r.id == reqId) updated else r,
            ],
          )
        else
          goal,
    ];
    _persist();
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});
