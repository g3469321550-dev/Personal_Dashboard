import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_container.dart';
import '../providers/schedule_provider.dart';
import '../providers/goal_provider.dart';
import '../models/schedule_item.dart';
import '../models/goal.dart';

class _RequirementEntry {
  final Goal goal;
  final DailyRequirement requirement;
  _RequirementEntry(this.goal, this.requirement);
}

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(scheduleProvider);
    final goals = ref.watch(goalProvider);
    final notifier = ref.read(scheduleProvider.notifier);
    final todayItems = notifier.itemsForDate(_selectedDay);

    final selectedDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final requirementEntries = <_RequirementEntry>[];
    for (final goal in goals) {
      if (goal.status != GoalStatus.active) continue;
      final start = DateTime(goal.startDate.year, goal.startDate.month, goal.startDate.day);
      final end = DateTime(goal.endDate.year, goal.endDate.month, goal.endDate.day);
      if (selectedDate.isBefore(start) || selectedDate.isAfter(end)) continue;
      for (final req in goal.dailyRequirements) {
        requirementEntries.add(_RequirementEntry(goal, req));
      }
    }

    final bool hasItems = todayItems.isNotEmpty || requirementEntries.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('日程'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/planning'),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            locale: 'zh_CN',
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600) ??
                  const TextStyle(),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: AppColors.error),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: theme.colorScheme.outline, fontSize: 13),
              weekendStyle:
                  TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    DateFormat('M月d日 EEEE', 'zh_CN').format(_selectedDay),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: !hasItems
                      ? Center(
                          child: Text(
                            '当天没有事项',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            for (final item in todayItems)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildScheduleCard(context, theme, item),
                              ),
                            for (final entry in requirementEntries)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _buildRequirementCard(context, theme, entry),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRequirementCard(
      BuildContext context, ThemeData theme, _RequirementEntry entry) {
    final isCompleted = entry.requirement.isCompletedOn(_selectedDay);
    return CardContainer(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(goalProvider.notifier).toggleRequirementCompletion(
                    entry.goal.id,
                    entry.requirement.id,
                    _selectedDay,
                  );
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      entry.goal.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.requirement.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? theme.colorScheme.outline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
      BuildContext context, ThemeData theme, ScheduleItem item) {
    Color priorityColor;
    switch (item.priority) {
      case SchedulePriority.high:
        priorityColor = AppColors.priorityHigh;
      case SchedulePriority.medium:
        priorityColor = AppColors.priorityMedium;
      default:
        priorityColor = AppColors.priorityLow;
    }

    return CardContainer(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref.read(scheduleProvider.notifier).toggleCompletion(item.id);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color:
                      item.isCompleted ? AppColors.success : AppColors.primary,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!item.isAllDay && item.startTime != null)
                  Text(
                    item.endTime != null
                        ? '${item.startTime} - ${item.endTime}'
                        : item.startTime!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration:
                              item.isCompleted ? TextDecoration.lineThrough : null,
                          color: item.isCompleted ? theme.colorScheme.outline : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 0.5),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, theme, item);
              } else if (value == 'delete') {
                ref.read(scheduleProvider.notifier).deleteItem(item.id);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('编辑')),
              const PopupMenuItem(value: 'delete', child: Text('删除')),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool isAllDay = true;
    SchedulePriority priority = SchedulePriority.medium;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新建事项'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('全天'),
                  value: isAllDay,
                  onChanged: (v) => setDialogState(() => isAllDay = v),
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isAllDay) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(startTime != null
                        ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                        : '开始时间'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) {
                        setDialogState(() => startTime = t);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(endTime != null
                        ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                        : '结束时间'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) {
                        setDialogState(() => endTime = t);
                      }
                    },
                  ),
                ],
                DropdownButton<SchedulePriority>(
                  value: priority,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: SchedulePriority.high,
                      child: Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.priorityHigh,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('高优先级'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: SchedulePriority.medium,
                      child: Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.priorityMedium,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('中优先级'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: SchedulePriority.low,
                      child: Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.priorityLow,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('低优先级'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => priority = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(scheduleProvider.notifier).createItem(
                        title: controller.text.trim(),
                        date: _selectedDay,
                        startTime: isAllDay ? null : startTime,
                        endTime: isAllDay ? null : endTime,
                        isAllDay: isAllDay,
                        priority: priority,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ThemeData theme, ScheduleItem item) {
    final controller = TextEditingController(text: item.title);
    TimeOfDay? startTime = item.startTime != null
        ? TimeOfDay(
            hour: int.parse(item.startTime!.split(':')[0]),
            minute: int.parse(item.startTime!.split(':')[1]),
          )
        : null;
    TimeOfDay? endTime = item.endTime != null
        ? TimeOfDay(
            hour: int.parse(item.endTime!.split(':')[0]),
            minute: int.parse(item.endTime!.split(':')[1]),
          )
        : null;
    bool isAllDay = item.isAllDay;
    SchedulePriority priority = item.priority;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('编辑事项'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('全天'),
                  value: isAllDay,
                  onChanged: (v) => setDialogState(() => isAllDay = v),
                  contentPadding: EdgeInsets.zero,
                ),
                if (!isAllDay) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(startTime != null
                        ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                        : '开始时间'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: startTime ?? TimeOfDay.now(),
                      );
                      if (t != null) {
                        setDialogState(() => startTime = t);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(endTime != null
                        ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                        : '结束时间'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: endTime ?? TimeOfDay.now(),
                      );
                      if (t != null) {
                        setDialogState(() => endTime = t);
                      }
                    },
                  ),
                ],
                DropdownButton<SchedulePriority>(
                  value: priority,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: SchedulePriority.high,
                      child: Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.priorityHigh,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('高优先级'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: SchedulePriority.medium,
                      child: Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.priorityMedium,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('中优先级'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: SchedulePriority.low,
                      child: Row(
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: AppColors.priorityLow,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Text('低优先级'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => priority = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                String? startStr;
                String? endStr;
                if (!isAllDay) {
                  if (startTime != null) {
                    startStr = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
                  }
                  if (endTime != null) {
                    endStr = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
                  }
                }
                final updated = item.copyWith(
                  title: controller.text.trim(),
                  isAllDay: isAllDay,
                  startTime: startStr,
                  endTime: endStr,
                  priority: priority,
                );
                ref.read(scheduleProvider.notifier).updateItem(item.id, updated);
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
