import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_config.dart';

class AiConfigNotifier extends StateNotifier<AiConfig> {
  static const _key = 'ai_config';

  AiConfigNotifier() : super(AiConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      state = AiConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  Future<void> update({String? baseUrl, String? model}) async {
    state = state.copyWith(baseUrl: baseUrl, model: model);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.toJson()));
  }
}

final aiConfigProvider =
    StateNotifierProvider<AiConfigNotifier, AiConfig>((ref) {
  return AiConfigNotifier();
});
