/// A single chat message between two users.
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.text,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id:             map['id'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      senderId:       map['senderId'] as String? ?? '',
      senderName:     map['senderName'] as String? ?? 'Utilisateur',
      senderPhotoUrl: map['senderPhotoUrl'] as String?,
      text:           map['text'] as String? ?? '',
      imageUrl:       map['imageUrl'] as String?,
      isRead:         map['isRead'] as bool? ?? false,
      createdAt:      _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':             id,
      'conversationId': conversationId,
      'senderId':       senderId,
      'senderName':     senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text':           text,
      'imageUrl':       imageUrl,
      'isRead':         isRead,
      'createdAt':      createdAt,
    };
  }

  MessageModel copyWith({bool? isRead}) {
    return MessageModel(
      id:             id,
      conversationId: conversationId,
      senderId:       senderId,
      senderName:     senderName,
      senderPhotoUrl: senderPhotoUrl,
      text:           text,
      imageUrl:       imageUrl,
      isRead:         isRead ?? this.isRead,
      createdAt:      createdAt,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MessageModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
