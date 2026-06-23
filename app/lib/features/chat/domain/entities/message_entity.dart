class MessageEntity {
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  const MessageEntity({
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
