/// Represents a conversation thread between two users, optionally linked to an item.
class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames; // {uid: name}
  final Map<String, String?> participantPhotos; // {uid: photoUrl}
  final String? itemId;
  final String? itemTitle;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount; // {uid: count}

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotos,
    this.itemId,
    this.itemTitle,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  int getUnreadCountFor(String uid) => unreadCount[uid] ?? 0;

  String getOtherParticipantId(String myUid) =>
      participantIds.firstWhere((id) => id != myUid, orElse: () => '');

  String getOtherParticipantName(String myUid) {
    final otherId = getOtherParticipantId(myUid);
    return participantNames[otherId] ?? 'Utilisateur';
  }

  String? getOtherParticipantPhoto(String myUid) {
    final otherId = getOtherParticipantId(myUid);
    return participantPhotos[otherId];
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id:               map['id'] as String? ?? '',
      participantIds:   List<String>.from(map['participantIds'] as List? ?? []),
      participantNames: Map<String, String>.from(
                          map['participantNames'] as Map? ?? {}),
      participantPhotos: (map['participantPhotos'] as Map? ?? {}).map(
                           (k, v) => MapEntry(k as String, v as String?)),
      itemId:           map['itemId'] as String?,
      itemTitle:        map['itemTitle'] as String?,
      lastMessage:      map['lastMessage'] as String? ?? '',
      lastMessageAt:    _parseDate(map['lastMessageAt']),
      unreadCount:      (map['unreadCount'] as Map? ?? {}).map(
                          (k, v) => MapEntry(k as String, (v as num).toInt())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':               id,
      'participantIds':   participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'itemId':           itemId,
      'itemTitle':        itemTitle,
      'lastMessage':      lastMessage,
      'lastMessageAt':    lastMessageAt,
      'unreadCount':      unreadCount,
    };
  }

  ConversationModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
  }) {
    return ConversationModel(
      id:               id,
      participantIds:   participantIds,
      participantNames: participantNames,
      participantPhotos: participantPhotos,
      itemId:           itemId,
      itemTitle:        itemTitle,
      lastMessage:      lastMessage ?? this.lastMessage,
      lastMessageAt:    lastMessageAt ?? this.lastMessageAt,
      unreadCount:      unreadCount ?? this.unreadCount,
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
      identical(this, other) || (other is ConversationModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
