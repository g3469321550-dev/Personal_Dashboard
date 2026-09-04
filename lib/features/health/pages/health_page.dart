import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/placeholder_card.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/health_provider.dart';
import '../models/sleep_record.dart';
import '../models/exercise_record.dart';

class HealthPage extends ConsumerWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('健康'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康数据',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '集中管理你的睡眠和运动数据',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            const PlaceholderCard(
              title: '睡眠分析',
              icon: Icons.bedtime,
            ),
            const SizedBox(height: 12),
            const PlaceholderCard(
              title: '运动记录',
              icon: Icons.directions_run,
            ),
            const SizedBox(height: 12),
            const PlaceholderCard(
              title: 'AI 健康分析',
              icon: Icons.analytics,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSleepInputDialog(context, ref),
                    icon: const Icon(Icons.bedtime, size: 18),
                    label: const Text('记录睡眠'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showExerciseInputDialog(context, ref),
                    icon: const Icon(Icons.directions_run, size: 18),
                    label: const Text('记录运动'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepInputDialog(BuildContext context, WidgetRef ref) {
    DateTime date = DateTime.now();
    TimeOfDay bedtime = const TimeOfDay(hour: 23, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);
    int quality = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('记录睡眠'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('日期: ${date.month}/${date.day}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setDialogState(() => date = d);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    '入睡: ${bedtime.hour.toString().padLeft(2, '0')}:${bedtime.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: bedtime,
                  );
                  if (t != null) setDialogState(() => bedtime = t);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                    '起床: ${wakeTime.hour.toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: wakeTime,
                  );
                  if (t != null) setDialogState(() => wakeTime = t);
                },
              ),
              const SizedBox(height: 8),
              Text('睡眠质量'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < quality ? Icons.star : Icons.star_border,
                      color: AppColors.accent,
                    ),
                    onPressed: () => setDialogState(() => quality = i + 1),
                  );
                }),
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
                final bedDt = DateTime(date.year, date.month, date.day,
                    bedtime.hour, bedtime.minute);
                final wakeDt = DateTime(date.year, date.month, date.day + 1,
                    wakeTime.hour, wakeTime.minute);
                final total = wakeDt.difference(bedDt);

                ref.read(healthProvider.notifier).addSleepRecord(
                      SleepRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: date,
                        bedtime: bedDt,
                        wakeTime: wakeDt,
                        totalDuration: total,
                        qualityScore: quality * 20,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseInputDialog(BuildContext context, WidgetRef ref) {
    DateTime date = DateTime.now();
    ExerciseType type = ExerciseType.running;
    int duration = 30;
    int calories = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('记录运动'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('日期: ${date.month}/${date.day}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setDialogState(() => date = d);
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('运动类型'),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ExerciseType.values.map((t) {
                  final isSelected = t == type;
                  return ChoiceChip(
                    label: Text(_exerciseTypeName(t)),
                    selected: isSelected,
                    onSelected: (_) => setDialogState(() => type = t),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryDark
                          : null,
                      fontWeight:
                          isSelected ? FontWeight.w600 : null,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(ctx).colorScheme.outlineVariant,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('时长(分钟): '),
                  Expanded(
                    child: Slider(
                      value: duration.toDouble(),
                      min: 5,
                      max: 180,
                      divisions: 35,
                      label: '$duration',
                      onChanged: (v) =>
                          setDialogState(() => duration = v.round()),
                    ),
                  ),
                ],
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
                ref.read(healthProvider.notifier).addExerciseRecord(
                      ExerciseRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: date,
                        type: type,
                        duration: Duration(minutes: duration),
                        calories: calories,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  String _exerciseTypeName(ExerciseType type) {
    switch (type) {
      case ExerciseType.running:
        return '跑步';
      case ExerciseType.walking:
        return '步行';
      case ExerciseType.cycling:
        return '骑行';
      case ExerciseType.swimming:
        return '游泳';
      case ExerciseType.strength:
        return '力量训练';
      case ExerciseType.yoga:
        return '瑜伽';
      case ExerciseType.basketball:
        return '篮球';
      case ExerciseType.football:
        return '足球';
      case ExerciseType.other:
        return '其他';
    }
  }
}
