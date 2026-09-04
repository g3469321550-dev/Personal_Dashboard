import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_container.dart';
import '../providers/chat_provider.dart';
import '../models/ai_character.dart';

class CharacterManagePage extends ConsumerWidget {
  const CharacterManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('角色管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chat'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _importCharacter(context, ref),
                icon: const Icon(Icons.file_upload, size: 18),
                label: const Text('导入角色 (JSON)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: chatState.characters.isEmpty
                ? Center(
                    child: Text(
                      '还没有角色，点击上方按钮导入',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: chatState.characters.length,
                    itemBuilder: (context, index) {
                      final character = chatState.characters[index];
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(chatProvider.notifier)
                              .selectCharacter(character.id);
                          context.go('/chat');
                        },
                        onLongPress: () =>
                            _showCharacterMenu(context, ref, character),
                        child: CardContainer(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  character.name.characters.first,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                character.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _personalityLabel(character.personality),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _personalityLabel(CharacterPersonality p) {
    switch (p) {
      case CharacterPersonality.strict:
        return '严格';
      case CharacterPersonality.gentle:
        return '温柔';
      case CharacterPersonality.neutral:
        return '中性';
    }
  }

  void _showCharacterMenu(
      BuildContext context, WidgetRef ref, AiCharacter character) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateDialog(context, ref, character: character);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('导出 JSON'),
              onTap: () {
                Navigator.pop(ctx);
                _exportCharacter(context, character);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('删除', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(chatProvider.notifier).deleteCharacter(character.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importCharacter(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;

      final content = await File(result.files.first.path!).readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      final character = AiCharacter.fromJsonImport(json);

      ref.read(chatProvider.notifier).addCharacter(character);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导入角色: ${character.name}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _exportCharacter(BuildContext context, AiCharacter character) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中')),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref,
      {AiCharacter? character}) {
    final nameController =
        TextEditingController(text: character?.name ?? '');
    final promptController =
        TextEditingController(text: character?.systemPrompt ?? '');
    final greetingController =
        TextEditingController(text: character?.greeting ?? '');
    var personality = character?.personality ?? CharacterPersonality.neutral;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(character == null ? '新建角色' : '编辑角色'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '角色名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  decoration: const InputDecoration(
                    labelText: '系统提示词',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: greetingController,
                  decoration: const InputDecoration(
                    labelText: '开场白（选填）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButton<CharacterPersonality>(
                  value: personality,
                  isExpanded: true,
                  items: CharacterPersonality.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(_personalityLabel(p)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => personality = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;

                if (character == null) {
                  ref.read(chatProvider.notifier).addCharacter(AiCharacter(
                        id: '',
                        name: nameController.text.trim(),
                        systemPrompt: promptController.text.trim(),
                        greeting: greetingController.text.trim().isEmpty
                            ? null
                            : greetingController.text.trim(),
                        personality: personality,
                      ));
                } else {
                  ref.read(chatProvider.notifier).updateCharacter(
                        character.copyWith(
                          name: nameController.text.trim(),
                          systemPrompt: promptController.text.trim(),
                          greeting: greetingController.text.trim().isEmpty
                              ? null
                              : greetingController.text.trim(),
                          personality: personality,
                        ),
                      );
                }
                Navigator.pop(ctx);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
