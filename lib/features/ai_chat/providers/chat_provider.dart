import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/hive_init.dart';
import '../models/ai_character.dart';
import '../models/chat_message.dart';

const _uuid = Uuid();

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _loadCharacters();
  }

  void _loadCharacters() {
    final box = aiCharactersBox;
    final characters = box.values
        .map((e) => AiCharacter.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))))
        .toList();
    state = state.copyWith(characters: characters);
  }

  void selectCharacter(String characterId) {
    state = state.copyWith(selectedCharacterId: characterId);
    _loadMessages(characterId);
  }

  void _loadMessages(String characterId) {
    final box = chatMessagesBox;
    final messages = box.values
        .map((e) => ChatMessage.fromJson(
            Map<String, dynamic>.from(jsonDecode(e as String))))
        .where((m) => m.characterId == characterId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    state = state.copyWith(messages: messages);
  }

  void addMessage({
    required String characterId,
    required MessageRole role,
    required String content,
    String? imagePath,
  }) {
    final message = ChatMessage(
      id: _uuid.v4(),
      characterId: characterId,
      role: role,
      content: content,
      imagePath: imagePath,
    );

    final box = chatMessagesBox;
    box.put(message.id, jsonEncode(message.toJson()));

    if (characterId == state.selectedCharacterId) {
      state = state.copyWith(messages: [...state.messages, message]);
    }
  }

  void deleteMessage(String messageId) {
    chatMessagesBox.delete(messageId);
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != messageId).toList(),
    );
  }

  void addCharacter(AiCharacter character) {
    final box = aiCharactersBox;
    final c = character.id.isEmpty
        ? AiCharacter(
            id: _uuid.v4(),
            name: character.name,
            avatarPath: character.avatarPath,
            systemPrompt: character.systemPrompt,
            greeting: character.greeting,
            personality: character.personality,
            modelOverride: character.modelOverride,
            baseUrlOverride: character.baseUrlOverride,
            apiKeyOverride: character.apiKeyOverride,
            supportsVision: character.supportsVision,
          )
        : character;
    box.put(c.id, jsonEncode(c.toJson()));
    state = state.copyWith(characters: [...state.characters, c]);
  }

  void updateCharacter(AiCharacter character) {
    final box = aiCharactersBox;
    box.put(character.id, jsonEncode(character.toJson()));
    state = state.copyWith(
      characters: [
        for (final c in state.characters)
          if (c.id == character.id) character else c,
      ],
    );
  }

  void deleteCharacter(String id) {
    aiCharactersBox.delete(id);
    state = state.copyWith(
      characters: state.characters.where((c) => c.id != id).toList(),
      selectedCharacterId: state.selectedCharacterId == id
          ? null
          : state.selectedCharacterId,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

class ChatState {
  final List<AiCharacter> characters;
  final List<ChatMessage> messages;
  final String? selectedCharacterId;
  final bool isLoading;

  const ChatState({
    this.characters = const [],
    this.messages = const [],
    this.selectedCharacterId,
    this.isLoading = false,
  });

  AiCharacter? get selectedCharacter => characters
      .cast<AiCharacter?>()
      .firstWhere((c) => c?.id == selectedCharacterId, orElse: () => null);

  ChatState copyWith({
    List<AiCharacter>? characters,
    List<ChatMessage>? messages,
    String? selectedCharacterId,
    bool clearSelection = false,
    bool? isLoading,
  }) {
    return ChatState(
      characters: characters ?? this.characters,
      messages: messages ?? this.messages,
      selectedCharacterId: clearSelection
          ? null
          : (selectedCharacterId ?? this.selectedCharacterId),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
