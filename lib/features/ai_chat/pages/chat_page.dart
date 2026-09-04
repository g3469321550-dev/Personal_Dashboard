import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ai_service.dart';
import '../../settings/providers/ai_config_provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final theme = Theme.of(context);

    if (chatState.characters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI 聊天'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () => context.go('/chat/characters'),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                '还没有 AI 角色',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/chat/characters'),
                icon: const Icon(Icons.add),
                label: const Text('添加角色'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final character = chatState.selectedCharacter ?? chatState.characters.first;

    if (chatState.selectedCharacterId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).selectCharacter(character.id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                character.name.characters.first,
                style: TextStyle(color: AppColors.primary, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Text(character.name),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => context.go('/chat/characters'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        character.greeting ?? '你好！我是${character.name}，有什么可以帮你的？',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatState.messages[index];
                      return _buildMessageBubble(context, theme, msg);
                    },
                  ),
          ),
          if (chatState.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${character.name} 正在输入...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          _buildInputBar(context, theme, character),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, ThemeData theme, ChatMessage msg) {
    final isUser = msg.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Icon(Icons.smart_toy, size: 16, color: AppColors.primary),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.warmGray),
              ),
              child: Text(
                msg.content,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child:
                  const Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
      BuildContext context, ThemeData theme, dynamic character) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        border: Border(top: BorderSide(color: AppColors.warmGray)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: AppColors.warmGray),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(character),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _sendMessage(character),
              icon: const Icon(Icons.send),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(dynamic character) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final notifier = ref.read(chatProvider.notifier);
    notifier.addMessage(
      characterId: character.id,
      role: MessageRole.user,
      content: text,
    );
    _inputController.clear();

    notifier.setLoading(true);

    try {
      final aiConfig = ref.read(aiConfigProvider);
      final service = AiService(aiConfig);
      final history = ref.read(chatProvider).messages
          .where((m) => m.characterId == character.id)
          .toList();

      final response = await service.chat(
        character: character,
        history: history,
      );

      notifier.addMessage(
        characterId: character.id,
        role: MessageRole.assistant,
        content: response,
      );
    } catch (e) {
      notifier.addMessage(
        characterId: character.id,
        role: MessageRole.assistant,
        content: '出错了: $e',
      );
    } finally {
      notifier.setLoading(false);
    }
  }
}
