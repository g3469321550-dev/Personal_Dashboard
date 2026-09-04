import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      showRssOnHome: prefs.getBool('showRssOnHome') ?? true,
    );
  }

  Future<void> setShowRssOnHome(bool value) async {
    state = state.copyWith(showRssOnHome: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showRssOnHome', value);
  }
}

class SettingsState {
  final bool showRssOnHome;

  const SettingsState({this.showRssOnHome = true});

  SettingsState copyWith({bool? showRssOnHome}) {
    return SettingsState(showRssOnHome: showRssOnHome ?? this.showRssOnHome);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
