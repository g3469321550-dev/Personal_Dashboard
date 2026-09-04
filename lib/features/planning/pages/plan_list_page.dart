import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_container.dart';
import '../models/schedule_item.dart';
import '../providers/goal_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/schedule_edit_dialog.dart';

class PlanListPage extends ConsumerWidget {
  const PlanListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final schedules = ref.watch(scheduleProvider);
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayItems = ref.read(scheduleProvider.notifier).itemsForDate(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text('计划'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.go('/planning/schedule'),
            tooltip: '日程',
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => context.go('/planning/focus'),
            tooltip: '专注计时',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '今日日程',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (todayItems.isEmpty)
            CardContainer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '今天没有日程安排',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
            )
          else
            ...todayItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CardContainer(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref
                            .read(scheduleProvider.notifier)
                            .toggleCompletion(item.id),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.isCompleted
                                ? AppColors.success
                                : Colors.transparent,
                            border: Border.all(
                              color: item.isCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: item.isCompleted
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                decoration: item.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.isCompleted
                                    ? theme.colorScheme.outline
                                    : null,
                              ),
                            ),
                            if (item.startTime != null)
                              Text(
                                item.isAllDay
                                    ? '全天'
                                    : '${item.startTime}${item.endTime != null ? ' - ${item.endTime}' : ''}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (value) {
                          if (value == 'edit') {
                            showScheduleEditDialog(context, ref, item);
                          } else if (value == 'delete') {
                            ref
                                .read(scheduleProvider.notifier)
                                .deleteItem(item.id);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Text('编辑')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('删除')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          Text(
            '长期目标',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (goals.isEmpty)
            CardContainer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 48, color: theme.colorScheme.outline),
                      const SizedBox(height: 8),
                      Text(
                        '还没有目标，点击下方按钮创建',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...goals.map((goal) {
              final completedToday = goal.dailyRequirements
                  .where((r) => r.isCompletedOn(today))
                  .length;
              final totalReqs = goal.dailyRequirements.length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CardContainer(
                  onTap: () => context.push('/planning/detail/${goal.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.parseColorTag(goal.colorTag),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '活跃',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (goal.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          goal.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '今日 $completedToday/$totalReqs',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '截止 ${goal.endDate.month}/${goal.endDate.day}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/planning/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

}
