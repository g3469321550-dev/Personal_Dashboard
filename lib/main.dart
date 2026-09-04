import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/storage/hive_init.dart';
import 'core/theme/theme_provider.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh', null);
  await initHive();
  runApp(const ProviderScope(child: PersonalDashboardApp()));
}

class PersonalDashboardApp extends ConsumerWidget {
  const PersonalDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).themeData;
    return MaterialApp.router(
      title: 'Personal Dashboard',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
