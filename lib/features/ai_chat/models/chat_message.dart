class ChatMessage {
  final String id;
  final String characterId;
  final MessageRole role;
  final String content;
  final String? imagePath;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.characterId,
    required this.role,
    required this.content,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'characterId': characterId,
        'role': role.name,
        'content': content,
        'imagePath': imagePath,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        characterId: json['characterId'] as String,
        role: MessageRole.values.firstWhere(
            (e) => e.name == json['role'],
            orElse: () => MessageRole.user),
        content: json['content'] as String,
        imagePath: json['imagePath'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

enum MessageRole { user, assistant, system }
