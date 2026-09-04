import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';

class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择主题',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              context,
              ref,
              name: '白色',
              mode: ThemeMode.light,
              currentMode: currentMode,
              bgColor: AppColors.warmWhite,
              textColor: AppColors.textLight,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              ref,
              name: '灰色',
              mode: ThemeMode.gray,
              currentMode: currentMode,
              bgColor: AppColors.warmGray,
              textColor: AppColors.textLight,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              ref,
              name: '黑色',
              mode: ThemeMode.dark,
              currentMode: currentMode,
              bgColor: AppColors.warmDark,
              textColor: AppColors.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Color bgColor,
    required Color textColor,
  }) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).setTheme(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: textColor,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
