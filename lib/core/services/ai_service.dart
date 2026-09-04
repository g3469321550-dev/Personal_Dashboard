import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';
import '../../features/ai_chat/models/ai_character.dart';
import '../../features/ai_chat/models/chat_message.dart';
import '../../features/settings/models/ai_config.dart';

class AiService {
  final AiConfig config;

  AiService(this.config);

  Future<String> chat({
    required AiCharacter character,
    required List<ChatMessage> history,
    String? imageBase64,
  }) async {
    final apiKey = character.apiKeyOverride ?? await SecureStorage.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key 未配置，请在设置中配置 AI API Key');
    }

    final baseUrl = character.baseUrlOverride ?? config.baseUrl;
    final model = character.modelOverride ?? config.model;

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': character.effectiveSystemPrompt},
      ...history.map((m) => {
            'role': m.role.name,
            'content': m.content,
          }),
    ];

    if (imageBase64 != null && character.supportsVision) {
      messages.last = {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': messages.last['content']},
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'},
          },
        ],
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI 请求失败: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  Future<bool> testConnection() async {
    try {
      final apiKey = await SecureStorage.getApiKey();
      if (apiKey == null || apiKey.isEmpty) return false;

      final response = await http.post(
        Uri.parse('${config.baseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': config.model,
          'messages': [
            {'role': 'user', 'content': 'Hi'},
          ],
          'max_tokens': 5,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
