import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/focus_timer_provider.dart';
import '../models/focus_session.dart';

const _uuid = Uuid();

class FocusTimerPage extends ConsumerStatefulWidget {
  const FocusTimerPage({super.key});

  @override
  ConsumerState<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends ConsumerState<FocusTimerPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusTimerProvider);
    final notifier = ref.read(focusTimerProvider.notifier);
    final theme = Theme.of(context);
    final categories = state.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('专注计时'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/planning'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/planning/focus/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, notifier),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCategoryBar(theme, categories, state, notifier),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimerRing(theme, state),
                  const SizedBox(height: 32),
                  _buildControls(theme, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(
      ThemeData theme,
      List<FocusCategory> categories,
      FocusTimerState state,
      FocusTimerNotifier notifier) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...categories.map((cat) {
            final isSelected = state.selectedCategory?.id == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onLongPress: state.timerState == TimerState.idle
                    ? () => _confirmDeleteCategory(context, notifier, cat)
                    : null,
                child: FilterChip(
                  label: Text(cat.name),
                  selected: isSelected,
                  onSelected: state.timerState == TimerState.idle
                      ? (_) => notifier.selectCategory(cat)
                      : null,
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('新建'),
              onPressed: () => _showAddCategoryDialog(context, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerRing(ThemeData theme, FocusTimerState state) {
    final total = state.plannedDuration.inMilliseconds.toDouble();
    final remaining = state.remaining.inMilliseconds.toDouble();
    final progress = total > 0 ? (total - remaining) / total : 0.0;

    final minutes = state.remaining.inMinutes;
    final seconds = state.remaining.inSeconds.remainder(60);

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(240, 240),
            painter: _TimerRingPainter(
              progress: progress,
              color: AppColors.primary,
              backgroundColor: AppColors.warmGray,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (state.selectedCategory != null)
                Text(
                  state.selectedCategory!.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
      ThemeData theme, FocusTimerState state, FocusTimerNotifier notifier) {
    return Column(
      children: [
        if (state.timerState == TimerState.idle) ...[
          _buildDurationSelector(theme, state, notifier),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: state.selectedCategory != null ? notifier.start : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('开始'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            ),
          ),
        ],
        if (state.timerState == TimerState.running)
          FilledButton.icon(
            onPressed: notifier.pause,
            icon: const Icon(Icons.pause),
            label: const Text('暂停'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        if (state.timerState == TimerState.paused) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: notifier.resume,
                icon: const Icon(Icons.play_arrow),
                label: const Text('继续'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: notifier.stop,
                icon: const Icon(Icons.stop),
                label: const Text('结束'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDurationSelector(
      ThemeData theme, FocusTimerState state, FocusTimerNotifier notifier) {
    final presets = [15, 25, 45, 60];
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: presets.map((m) {
          final isSelected = state.plannedDuration.inMinutes == m;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text('${m}m'),
              selected: isSelected,
              onSelected: (_) =>
                  notifier.setPlannedDuration(Duration(minutes: m)),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, FocusTimerNotifier notifier) {
    int customMinutes = 25;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('自定义时长'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: customMinutes.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: '$customMinutes 分钟',
                onChanged: (v) =>
                    setDialogState(() => customMinutes = v.round()),
              ),
              Text('$customMinutes 分钟',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                notifier.setPlannedDuration(Duration(minutes: customMinutes));
                Navigator.pop(ctx);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteCategory(
      BuildContext context, FocusTimerNotifier notifier, FocusCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定删除「${category.name}」吗？相关的专注记录不会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, FocusTimerNotifier notifier) {
    final controller = TextEditingController();
    int selectedColorIndex = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新建分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: List.generate(AppColors.colorTags.length, (index) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedColorIndex = index),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.colorTags[index],
                        shape: BoxShape.circle,
                        border: index == selectedColorIndex
                            ? Border.all(
                                color: Theme.of(ctx).colorScheme.onSurface,
                                width: 2)
                            : null,
                      ),
                    ),
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
                if (controller.text.trim().isNotEmpty) {
                  final colorHex =
                      '0x${AppColors.colorTags[selectedColorIndex].toARGB32().toUnsigned(32).toRadixString(16).padLeft(8, '0')}';
                  notifier.addCategory(FocusCategory(
                    id: _uuid.v4(),
                    name: controller.text.trim(),
                    type: FocusCategoryType.custom,
                    colorHex: colorHex,
                  ));
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
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
