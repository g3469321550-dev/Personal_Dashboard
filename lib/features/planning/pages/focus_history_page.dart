import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_container.dart';
import '../providers/focus_timer_provider.dart';
import '../models/focus_session.dart';

class FocusHistoryPage extends ConsumerWidget {
  const FocusHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final sessions = notifier.getSessions()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final theme = Theme.of(context);

    final grouped = <String, List<FocusSession>>{};
    for (final session in sessions) {
      final key = DateFormat('yyyy-MM-dd').format(session.startTime);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(session);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('专注记录'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/planning/focus'),
        ),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    '还没有专注记录',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final daySessions = grouped[dateKey]!;
                final totalMinutes = daySessions
                    .fold<int>(0, (s, e) => s + e.actualDuration.inMinutes);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('M月d日 EEEE', 'zh_CN')
                                .format(DateTime.parse(dateKey)),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '共 $totalMinutes 分钟',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...daySessions.map((session) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CardContainer(
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: session.status ==
                                            FocusSessionStatus.completed
                                        ? AppColors.success
                                        : AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.categoryName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${session.actualDuration.inMinutes} 分钟',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 18),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditSessionDialog(context, ref, notifier, session);
                                    } else if (value == 'delete') {
                                      notifier.deleteSession(session.id);
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
                        )),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
    );
  }

  void _showEditSessionDialog(
    BuildContext context,
    WidgetRef ref,
    FocusTimerNotifier notifier,
    FocusSession session,
  ) {
    final categories = notifier.getCategories();
    final durationController = TextEditingController(
      text: session.actualDuration.inMinutes.toString(),
    );
    String? selectedCategoryId = session.categoryId;
    FocusSessionStatus selectedStatus = session.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('编辑专注记录'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: categories.any((c) => c.id == selectedCategoryId)
                    ? selectedCategoryId
                    : (categories.isNotEmpty ? categories.first.id : null),
                decoration: const InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                )).toList(),
                onChanged: (v) => setDialogState(() => selectedCategoryId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: '时长（分钟）',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<FocusSessionStatus>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: '状态',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: FocusSessionStatus.completed, child: Text('已完成')),
                  DropdownMenuItem(value: FocusSessionStatus.interrupted, child: Text('已中断')),
                  DropdownMenuItem(value: FocusSessionStatus.paused, child: Text('已暂停')),
                ],
                onChanged: (v) => setDialogState(() {
                  if (v != null) selectedStatus = v;
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
                final minutes = int.tryParse(durationController.text.trim());
                if (minutes == null || minutes <= 0) return;
                final category = categories.firstWhere(
                  (c) => c.id == selectedCategoryId,
                  orElse: () => categories.first,
                );
                final updated = session.copyWith(
                  categoryId: category.id,
                  categoryName: category.name,
                  actualDuration: Duration(minutes: minutes),
                  endTime: session.startTime.add(Duration(minutes: minutes)),
                  status: selectedStatus,
                );
                notifier.updateSession(session.id, updated);
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
