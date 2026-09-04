import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_container.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';

const _uuid = Uuid();

class PlanDetailPage extends ConsumerWidget {
  final String goalId;

  const PlanDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final goal = goals.cast<Goal?>().firstWhere(
        (g) => g?.id == goalId,
        orElse: () => null);
    final theme = Theme.of(context);
    final today = DateTime.now();

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('目标详情'),
          leading: BackButton(onPressed: () => context.go('/planning')),
        ),
        body: const Center(child: Text('目标不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        leading: BackButton(onPressed: () => context.go('/planning')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditGoalDialog(context, ref, goal),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.parseColorTag(goal.colorTag),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (goal.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      goal.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.date_range,
                          size: 16, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('yyyy/M/d').format(goal.startDate)} - ${DateFormat('yyyy/M/d').format(goal.endDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '每日要求',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (goal.dailyRequirements.isEmpty)
              CardContainer(
                child: Center(
                  child: Text(
                    '还没有每日要求',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              ...goal.dailyRequirements.map((req) {
                final isDone = req.isCompletedOn(today);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CardContainer(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(goalProvider.notifier)
                                .toggleRequirementCompletion(
                                    goalId, req.id, today);
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone ? AppColors.success : Colors.transparent,
                              border: Border.all(
                                color:
                                    isDone ? AppColors.success : AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            req.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? theme.colorScheme.outline : null,
                            ),
                          ),
                        ),
                        if (req.isQuantitative && req.targetValue != null)
                          Text(
                            '${req.targetValue}${req.unit ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditRequirementDialog(context, ref, goalId, req);
                            } else if (value == 'delete') {
                              ref.read(goalProvider.notifier).deleteRequirement(goalId, req.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('编辑')),
                            const PopupMenuItem(value: 'delete', child: Text('删除')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showAddRequirementDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加每日要求'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这个目标吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalProvider.notifier).deleteGoal(goalId);
              Navigator.pop(ctx);
              context.go('/planning');
            },
            child: Text(
              '删除',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRequirementDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加每日要求'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例如：阅读30分钟',
            border: OutlineInputBorder(),
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
                ref.read(goalProvider.notifier).addRequirement(
                      goalId,
                      DailyRequirement(
                        id: _uuid.v4(),
                        content: controller.text.trim(),
                      ),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, Goal goal) {
    final titleController = TextEditingController(text: goal.title);
    final descController = TextEditingController(text: goal.description ?? '');
    DateTime startDate = goal.startDate;
    DateTime endDate = goal.endDate;
    int selectedColorIndex = 0;
    if (goal.colorTag != null) {
      final idx = AppColors.colorTags.indexWhere((c) => '0x${c.toARGB32().toUnsigned(32).toRadixString(16).padLeft(8, '0')}' == goal.colorTag);
      if (idx >= 0) selectedColorIndex = idx;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('编辑目标'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '目标名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: '描述（选填）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setDialogState(() => startDate = d);
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text('${startDate.month}/${startDate.day}'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('至'),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: endDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setDialogState(() => endDate = d);
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text('${endDate.month}/${endDate.day}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  children: List.generate(AppColors.colorTags.length, (index) {
                    final color = AppColors.colorTags[index];
                    final isSelected = index == selectedColorIndex;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColorIndex = index),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Theme.of(ctx).colorScheme.onSurface, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }),
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
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                final colorValue = AppColors.colorTags[selectedColorIndex].toARGB32().toUnsigned(32);
                final colorHex = '0x${colorValue.toRadixString(16).padLeft(8, '0')}';
                final desc = descController.text.trim();
                ref.read(goalProvider.notifier).updateGoal(
                  goalId,
                  goal.copyWith(
                    title: title,
                    description: desc.isEmpty ? null : desc,
                    startDate: startDate,
                    endDate: endDate,
                    colorTag: colorHex,
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

  void _showEditRequirementDialog(BuildContext context, WidgetRef ref, String goalId, DailyRequirement req) {
    final controller = TextEditingController(text: req.content);
    final targetController = TextEditingController(
      text: req.targetValue?.toString() ?? '',
    );
    final unitController = TextEditingController(text: req.unit ?? '');
    bool isQuantitative = req.isQuantitative;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('编辑每日要求'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '内容',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('量化目标'),
                value: isQuantitative,
                onChanged: (v) => setDialogState(() => isQuantitative = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (isQuantitative) ...[
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(
                    labelText: '目标值',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(
                    labelText: '单位（选填）',
                    hintText: '如：分钟、页、次',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final content = controller.text.trim();
                if (content.isEmpty) return;
                final updated = req.copyWith(
                  content: content,
                  isQuantitative: isQuantitative,
                  targetValue: isQuantitative
                      ? (double.tryParse(targetController.text.trim()) ?? req.targetValue)
                      : null,
                  unit: isQuantitative ? unitController.text.trim() : null,
                );
                ref.read(goalProvider.notifier).updateRequirement(goalId, req.id, updated);
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
