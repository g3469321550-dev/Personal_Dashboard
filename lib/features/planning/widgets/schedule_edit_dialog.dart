import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/schedule_item.dart';
import '../providers/schedule_provider.dart';

void showScheduleEditDialog(BuildContext context, WidgetRef ref, ScheduleItem item) {
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
        content: Column(
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
