import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

/// ViewModel for messaging (conversations + messages).
class MessagesProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _activeMessages = [];
  String? _activeConversationId;
  bool _isLoading = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get activeMessages => _activeMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int getTotalUnread(String uid) {
    return _conversations.fold(0, (sum, c) => sum + c.getUnreadCountFor(uid));
  }

  /// Start watching conversations for the given user.
  void startWatchingConversations(String uid) {
    FirestoreService.instance.watchConversations(uid).listen(
      (convs) {
        _conversations = convs
          ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  /// Start watching messages for a specific conversation.
  void startWatchingMessages(String conversationId) {
    _activeConversationId = conversationId;
    _activeMessages = [];
    notifyListeners();

    FirestoreService.instance.watchMessages(conversationId).listen(
      (msgs) {
        if (_activeConversationId == conversationId) {
          _activeMessages = msgs;
          notifyListeners();
        }
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void stopWatchingMessages() {
    _activeConversationId = null;
    _activeMessages = [];
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
    try {
      return await FirestoreService.instance.getOrCreateConversation(
        myUid: myUid, myName: myName, myPhotoUrl: myPhotoUrl,
        otherUid: otherUid, otherName: otherName, otherPhotoUrl: otherPhotoUrl,
        itemId: itemId, itemTitle: itemTitle,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderPhotoUrl,
    required String text,
    String? imageUrl,
  }) async {
    if (text.trim().isEmpty && imageUrl == null) return false;
    try {
      await FirestoreService.instance.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        senderPhotoUrl: senderPhotoUrl,
        text: text.trim(),
        imageUrl: imageUrl,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(String conversationId, String uid) async {
    await FirestoreService.instance.markConversationRead(conversationId, uid);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
