import 'dart:convert';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/hive_init.dart';
import '../models/schedule_item.dart';

const _uuid = Uuid();

class ScheduleNotifier extends StateNotifier<List<ScheduleItem>> {
  ScheduleNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = schedulesBox;
    final items = <ScheduleItem>[];
    for (final e in box.values) {
      try {
        items.add(ScheduleItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))));
      } catch (e) {
        print('[ScheduleProvider] Failed to load schedule item: $e');
      }
    }
    state = items;
  }

  void _persist() {
    final box = schedulesBox;
    final currentKeys = box.keys.map((e) => e.toString()).toSet();
    final stateKeys = state.map((item) => item.id).toSet();

    for (final key in currentKeys) {
      if (!stateKeys.contains(key)) {
        box.delete(key);
      }
    }

    for (final item in state) {
      box.put(item.id, jsonEncode(item.toJson()));
    }
  }

  void addItem(ScheduleItem item) {
    state = [...state, item];
    _persist();
  }

  void updateItem(String id, ScheduleItem updated) {
    state = [for (final i in state) if (i.id == id) updated else i];
    _persist();
  }

  void deleteItem(String id) {
    state = state.where((i) => i.id != id).toList();
    _persist();
  }

  void toggleCompletion(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isCompleted: !item.isCompleted) else item,
    ];
    _persist();
  }

  List<ScheduleItem> itemsForDate(DateTime date) {
    try {
      return state.where((item) {
        if (item.recurrence != null) return _matchesRecurrence(item, date);
        return _sameDate(item.date, date);
      }).toList()
        ..sort((a, b) {
          try {
            if (a.isAllDay && !b.isAllDay) return -1;
            if (!a.isAllDay && b.isAllDay) return 1;
            if (a.startTime != null && b.startTime != null) {
              return a.startTime!.compareTo(b.startTime!);
            }
          } catch (_) {}
          return 0;
        });
    } catch (e) {
      print('[ScheduleProvider] itemsForDate error: $e');
      return [];
    }
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _matchesRecurrence(ScheduleItem item, DateTime date) {
    final rec = item.recurrence!;
    if (date.isBefore(item.date)) return false;
    if (rec.endDate != null && date.isAfter(rec.endDate!)) return false;

    switch (rec.type) {
      case RecurrenceType.daily:
        final days = date.difference(item.date).inDays;
        return days % rec.interval == 0;
      case RecurrenceType.weekly:
        final days = date.difference(item.date).inDays;
        if (days % (7 * rec.interval) != 0) {
          return rec.weekDays?.contains(date.weekday) ?? false;
        }
        return true;
      case RecurrenceType.monthly:
        return date.day == (rec.monthDay ?? item.date.day) &&
            _monthDiff(item.date, date) % rec.interval == 0;
      case RecurrenceType.yearly:
        return date.month == item.date.month && date.day == item.date.day;
    }
  }

  int _monthDiff(DateTime from, DateTime to) =>
      (to.year - from.year) * 12 + (to.month - from.month);

  ScheduleItem createItem({
    required String title,
    String? note,
    required DateTime date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool isAllDay = false,
    SchedulePriority priority = SchedulePriority.medium,
    String? goalId,
    String? goalRequirementId,
    RecurrenceRule? recurrence,
  }) {
    String? startStr;
    String? endStr;
    if (startTime != null) {
      startStr = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    }
    if (endTime != null) {
      endStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    }
    final item = ScheduleItem(
      id: _uuid.v4(),
      title: title,
      note: note,
      date: date,
      startTime: startStr,
      endTime: endStr,
      isAllDay: isAllDay,
      priority: priority,
      goalId: goalId,
      goalRequirementId: goalRequirementId,
      recurrence: recurrence,
    );
    addItem(item);
    return item;
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<ScheduleItem>>((ref) {
  return ScheduleNotifier();
});
