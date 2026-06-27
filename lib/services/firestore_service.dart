import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/conversation_model.dart';
import '../models/item_model.dart';
import '../models/message_model.dart';

/// Firestore operations used by [ItemsProvider] and [MessagesProvider].
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // Items
  // ─────────────────────────────────────────────────────────────────────────

  Stream<List<ItemModel>> watchItems() {
    // Fixed query: removed the 'status' filter which requires a composite index
    // and can cause the stream to hang or fail if not configured.
    // Filtering is better handled in the Provider for this scale.
    return _db
        .collection('items')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ItemModel.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<List<ItemModel>> getItems() async {
    final snap = await _db.collection('items').get();
    return snap.docs
        .map((d) => ItemModel.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> addItem(ItemModel item) async {
    debugPrint('[FirestoreService] Adding item: ${item.id}');
    final ref = _db.collection('items').doc(item.id);
    await ref.set(item.toMap());
    debugPrint('[FirestoreService] Item added successfully');
  }

  Future<void> updateItem(ItemModel item) async {
    final ref = _db.collection('items').doc(item.id);
    await ref.set(item.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteItem(String itemId) async {
    await _db.collection('items').doc(itemId).delete();
  }

  Future<List<ItemModel>> getPendingItems() async {
    final snap = await _db
        .collection('items')
        .where('status', isEqualTo: 'pending')
        .get();

    return snap.docs
        .map((d) => ItemModel.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Conversations
  // ─────────────────────────────────────────────────────────────────────────

  Stream<List<ConversationModel>> watchConversations(String uid) {
    return _db
        .collection('conversations')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ConversationModel.fromMap({'id': d.id, ...d.data()}))
            .toList())
        .map((list) {
      list.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return list;
    });
  }

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(
                {'id': d.id, 'conversationId': conversationId, ...d.data()}))
            .toList());
  }

  Future<ConversationModel?> getOrCreateConversation({
    required String myUid,
    required String myName,
    String? myPhotoUrl,
    required String otherUid,
    required String otherName,
    String? otherPhotoUrl,
    String? itemId,
    String? itemTitle,
  }) async {
    final participants = [myUid, otherUid]..sort();
    final convId = 'c_${participants[0]}_${participants[1]}';

    final convRef = _db.collection('conversations').doc(convId);
    final doc = await convRef.get();

    if (doc.exists) {
      if (itemId != null) {
        await convRef.update({
          'itemId': itemId,
          'itemTitle': itemTitle,
        });
      }
      return ConversationModel.fromMap({'id': convRef.id, ...doc.data() as Map});
    }

    final conversation = ConversationModel(
      id: convId,
      participantIds: [myUid, otherUid],
      participantNames: {myUid: myName, otherUid: otherName},
      participantPhotos: {myUid: myPhotoUrl, otherUid: otherPhotoUrl},
      itemId: itemId,
      itemTitle: itemTitle,
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      unreadCount: {myUid: 0, otherUid: 0},
    );

    await convRef.set(conversation.toMap());
    return conversation;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String text,
    String? imageUrl,
  }) async {
    final messageRef = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final createdAt = DateTime.now();

    await messageRef.set({
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'imageUrl': imageUrl,
      'isRead': false,
      'createdAt': createdAt,
    });

    final convRef = _db.collection('conversations').doc(conversationId);
    await _db.runTransaction((tx) async {
      final convSnap = await tx.get(convRef);
      if (!convSnap.exists) return;

      final convData = convSnap.data() as Map<String, dynamic>;
      final currentUnread = (convData['unreadCount'] as Map?)?.cast<String, dynamic>() ?? {};

      final participants = (convData['participantIds'] as List?)?.cast<String>() ?? [];
      final otherIds = participants.where((id) => id != senderId);

      final newUnreadCount = <String, int>{};
      for (final pid in participants) {
        newUnreadCount[pid] = (currentUnread[pid] ?? 0) as int;
      }
      for (final oid in otherIds) {
        newUnreadCount[oid] = (newUnreadCount[oid] ?? 0) + 1;
      }
      newUnreadCount[senderId] = 0;

      tx.update(convRef, {
        'lastMessage': text,
        'lastMessageAt': createdAt,
        'unreadCount': newUnreadCount,
      });
    });
  }

  Future<void> markConversationRead(String conversationId, String uid) async {
    final convRef = _db.collection('conversations').doc(conversationId);

    await _db.runTransaction((tx) async {
      final convSnap = await tx.get(convRef);
      if (!convSnap.exists) return;

      final convData = convSnap.data() as Map<String, dynamic>;
      final unreadCount = (convData['unreadCount'] as Map?)?.cast<String, dynamic>() ?? {};

      final newUnreadCount = <String, int>{};
      unreadCount.forEach((k, v) {
        newUnreadCount[k] = (v as num).toInt();
      });
      newUnreadCount[uid] = 0;

      tx.update(convRef, {'unreadCount': newUnreadCount});

      final msgs = await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('senderId', isNotEqualTo: uid)
          .get();

      for (final d in msgs.docs) {
        tx.update(d.reference, {'isRead': true});
      }
    });
  }

  Future<void> updateItemCore({required String itemId, required Map<String, dynamic> data}) {
    return _db.collection('items').doc(itemId).update(data);
  }

  Future<void> mergeItem(ItemModel item) async {
    final ref = _db.collection('items').doc(item.id);
    await ref.set(item.toMap(), SetOptions(merge: true));
  }
}
