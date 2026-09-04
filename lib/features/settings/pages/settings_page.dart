import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/card_container.dart';
import '../../settings/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '外观',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          CardContainer(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('主题'),
                  subtitle: Text(_themeName(ref.watch(themeModeProvider))),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/theme'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI 设置',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          CardContainer(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.key),
                  title: const Text('API 配置'),
                  subtitle: const Text('配置 AI 服务地址和密钥'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/settings/api-key'),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.people_outline),
                  title: const Text('角色管理'),
                  subtitle: const Text('管理 AI 角色和人设'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/chat/characters'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '功能',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          CardContainer(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('首页显示资讯'),
                  subtitle: const Text('在首页底部展示 RSS 订阅内容'),
                  value: settings.showRssOnHome,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setShowRssOnHome(v),
                  secondary: const Icon(Icons.rss_feed),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '关于',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          CardContainer(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于应用'),
                  subtitle: const Text('Personal Dashboard v1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '白色';
      case ThemeMode.gray:
        return '灰色';
      case ThemeMode.dark:
        return '黑色';
    }
  }
}
