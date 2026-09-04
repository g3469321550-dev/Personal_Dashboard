import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/card_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../planning/providers/goal_provider.dart';
import '../../planning/providers/schedule_provider.dart';
import '../../planning/providers/focus_timer_provider.dart';
import '../../planning/models/goal.dart';
import '../../planning/models/schedule_item.dart';
import '../../planning/models/focus_session.dart';
import '../../health/providers/health_provider.dart';

class _HomeRequirementEntry {
  final Goal goal;
  final DailyRequirement requirement;
  _HomeRequirementEntry(this.goal, this.requirement);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final health = ref.watch(healthProvider);
    final schedules = ref.watch(scheduleProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theme = Theme.of(context);

    final todaySchedules =
        ref.read(scheduleProvider.notifier).itemsForDate(today);
    final activeGoals = (goals ?? []).where((g) => g.status == GoalStatus.active).toList();

    final requirementEntries = <_HomeRequirementEntry>[];
    for (final goal in activeGoals) {
      final start = DateTime(goal.startDate.year, goal.startDate.month, goal.startDate.day);
      final end = DateTime(goal.endDate.year, goal.endDate.month, goal.endDate.day);
      if (today.isBefore(start) || today.isAfter(end)) continue;
      for (final req in goal.dailyRequirements) {
        requirementEntries.add(_HomeRequirementEntry(goal, req));
      }
    }

    final todayFocusSessions =
        ref.read(focusTimerProvider.notifier).getSessions(date: today);
    final totalFocusMinutes = todayFocusSessions
        .fold<int>(0, (sum, s) => sum + s.actualDuration.inMinutes);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(theme, today),
            const SizedBox(height: 20),
            _buildCardSafe('todaySchedule', theme, () => _buildTodayScheduleCard(context, ref, theme, todaySchedules, requirementEntries, today)),
            const SizedBox(height: 16),
            _buildCardSafe('activeGoals', theme, () => _buildActiveGoalsCard(context, ref, theme, activeGoals)),
            const SizedBox(height: 16),
            _buildCardSafe('focusSummary', theme, () => _buildFocusSummaryCard(context, ref, theme, todayFocusSessions, totalFocusMinutes)),
            const SizedBox(height: 16),
            _buildCardSafe('healthSummary', theme, () => _buildHealthSummaryCard(context, theme, health, today)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSafe(String name, ThemeData theme, Widget Function() builder) {
    try {
      return builder();
    } catch (e, st) {
      print('[HomePage] ERROR in $name: $e\n$st');
      return CardContainer(
        child: Text('卡片加载失败: $name', style: TextStyle(color: AppColors.error)),
      );
    }
  }

  static const List<String> _dailyQuotes = [
    '千里之行，始于足下。',
    '不积跬步，无以至千里。',
    '学而不思则罔，思而不学则殆。',
    '天行健，君子以自强不息。',
    '业精于勤，荒于嬉。',
    '路漫漫其修远兮，吾将上下而求索。',
    '知之为知之，不知为不知，是知也。',
    '三人行，必有我师焉。',
    '己所不欲，勿施于人。',
    '温故而知新，可以为师矣。',
    '博学之，审问之，慎思之，明辨之，笃行之。',
    '锲而不舍，金石可镂。',
    '世上无难事，只怕有心人。',
    '宝剑锋从磨砺出，梅花香自苦寒来。',
    '长风破浪会有时，直挂云帆济沧海。',
    '会当凌绝顶，一览众山小。',
    '沉舟侧畔千帆过，病树前头万木春。',
    '山重水复疑无路，柳暗花明又一村。',
    '纸上得来终觉浅，绝知此事要躬行。',
    '问渠那得清如许，为有源头活水来。',
    '莫等闲，白了少年头，空悲切。',
    '老骥伏枥，志在千里。',
    '穷且益坚，不坠青云之志。',
    '天生我材必有用。',
    '海内存知己，天涯若比邻。',
    '落红不是无情物，化作春泥更护花。',
    '春蚕到死丝方尽，蜡炬成灰泪始干。',
    '随风潜入夜，润物细无声。',
    '欲穷千里目，更上一层楼。',
    '不畏浮云遮望眼，自缘身在最高层。',
  ];

  String _getDailyQuote(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return _dailyQuotes[dayOfYear % _dailyQuotes.length];
  }

  Widget _buildDateHeader(ThemeData theme, DateTime today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('M月d日 EEEE', 'zh_CN').format(today),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getDailyQuote(today),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayScheduleCard(
      BuildContext context, WidgetRef ref, ThemeData theme, List<dynamic> schedules, List<_HomeRequirementEntry> requirementEntries, DateTime today) {
    final totalCount = schedules.length + requirementEntries.length;
    final isEmpty = schedules.isEmpty && requirementEntries.isEmpty;

    return CardContainer(
      onTap: () => context.go('/planning/schedule'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日待办',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$totalCount 项',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '今天没有待办事项',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else ...[
            ...schedules.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(scheduleProvider.notifier).toggleCompletion(item.id),
                        child: Icon(
                          item.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: item.isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.startTime != null)
                        Text(
                          '${item.startTime} ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          item.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isCompleted
                                ? theme.colorScheme.outline
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildPriorityDot(item.priority),
                    ],
                  ),
                )),
            ..._buildGroupedRequirements(ref, theme, requirementEntries, today),
            if (totalCount > 3)
              Text(
                '还有 ${totalCount - 3} 项...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityDot(dynamic priority) {
    Color color;
    switch (priority) {
      case SchedulePriority.high:
        color = AppColors.priorityHigh;
      case SchedulePriority.medium:
        color = AppColors.priorityMedium;
      default:
        color = AppColors.priorityLow;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  List<Widget> _buildGroupedRequirements(
      WidgetRef ref, ThemeData theme, List<_HomeRequirementEntry> entries, DateTime today) {
    final grouped = <String, List<_HomeRequirementEntry>>{};
    for (final e in entries) {
      (grouped[e.goal.id] ??= []).add(e);
    }
    final widgets = <Widget>[];
    for (final goalEntries in grouped.values) {
      final goal = goalEntries.first.goal;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 4),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.parseColorTag(goal.colorTag),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                goal.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ));
      for (final entry in goalEntries) {
        final isCompleted = entry.requirement.isCompletedOn(today);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 18),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => ref.read(goalProvider.notifier).toggleRequirementCompletion(
                  goal.id,
                  entry.requirement.id,
                  today,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.requirement.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: isCompleted
                        ? theme.colorScheme.outline
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ));
      }
    }
    return widgets;
  }

  Widget _buildActiveGoalsCard(
      BuildContext context, WidgetRef ref, ThemeData theme, List<Goal> goals) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return CardContainer(
      onTap: () => context.go('/planning'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '活跃目标',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${goals.length} 个',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '还没有设定目标，点击添加',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            ...goals.take(3).map((goal) {
              final completedCount = goal.dailyRequirements.where((r) => r.isCompletedOn(today)).length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.parseColorTag(goal.colorTag),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push('/planning/detail/${goal.id}'),
                        child: Text(
                          goal.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      '$completedCount/${goal.dailyRequirements.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFocusSummaryCard(
      BuildContext context, WidgetRef ref, ThemeData theme, List<FocusSession> sessions, int totalMinutes) {
    final categoryData = <String, int>{};
    for (final s in sessions) {
      categoryData[s.categoryName] = (categoryData[s.categoryName] ?? 0) + s.actualDuration.inMinutes;
    }
    final total = categoryData.values.fold<int>(0, (a, b) => a + b);
    final entries = categoryData.entries.toList();

    return CardContainer(
      onTap: () => context.go('/planning/focus'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日专注',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '共 $totalMinutes 分钟',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  '今天还没有专注记录',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;
                    final pct = total > 0 ? (e.value / total * 100) : 0.0;
                    final color = AppColors.colorTags[index % AppColors.colorTags.length];
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      color: color,
                      radius: 60,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...entries.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              final pct = total > 0 ? (e.value / total * 100) : 0.0;
              final color = AppColors.colorTags[index % AppColors.colorTags.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%  ${e.value}分钟',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthSummaryCard(
      BuildContext context, ThemeData theme, dynamic health, DateTime today) {
    final todaySleep = health.sleepRecords.where((r) =>
        r.date.year == today.year &&
        r.date.month == today.month &&
        r.date.day == today.day);
    final todayExercise = health.exerciseRecords.where((r) =>
        r.date.year == today.year &&
        r.date.month == today.month &&
        r.date.day == today.day);

    return CardContainer(
      onTap: () => context.go('/health'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '健康摘要',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHealthItem(
                  theme,
                  Icons.bedtime,
                  '睡眠',
                  todaySleep.isNotEmpty
                      ? '${todaySleep.last.totalDuration.inHours}h${todaySleep.last.totalDuration.inMinutes.remainder(60)}m'
                      : '未记录',
                ),
              ),
              Expanded(
                child: _buildHealthItem(
                  theme,
                  Icons.directions_run,
                  '运动',
                  todayExercise.isNotEmpty
                      ? '${todayExercise.last.duration.inMinutes}分钟'
                      : '未记录',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(
      ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
