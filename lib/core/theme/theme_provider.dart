import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

enum ThemeMode { light, gray, dark }

class ThemeState {
  final ThemeData themeData;
  final ThemeMode mode;

  ThemeState(this.themeData, this.mode);
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _key = 'theme_mode';

  ThemeNotifier() : super(ThemeState(AppTheme.light, ThemeMode.light)) {
    _loadTheme();
  }

  ThemeMode get currentMode => state.mode;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_key) ?? 'light';
    final mode = ThemeMode.values.firstWhere((e) => e.name == modeStr, orElse: () => ThemeMode.light);
    state = ThemeState(_themeForMode(mode), mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = ThemeState(_themeForMode(mode), mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  ThemeData _themeForMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => AppTheme.light,
      ThemeMode.gray => AppTheme.gray,
      ThemeMode.dark => AppTheme.dark,
    };
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).mode;
});
