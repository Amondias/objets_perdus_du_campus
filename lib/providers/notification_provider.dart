import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

/// ViewModel for push notification state.
class NotificationProvider extends ChangeNotifier {
  String? _fcmToken;
  final List<Map<String, dynamic>> _inAppNotifications = [];

  String? get fcmToken => _fcmToken;
  List<Map<String, dynamic>> get notifications =>
      List.unmodifiable(_inAppNotifications);
  int get unreadNotificationsCount =>
      _inAppNotifications.where((n) => !(n['read'] as bool)).length;

  Future<void> initialize() async {
    await NotificationService.instance.initialize();
    _fcmToken = await NotificationService.instance.getToken();
    notifyListeners();
  }

  void addInAppNotification({
    required String title,
    required String body,
    String? type,
    String? targetId,
  }) {
    _inAppNotifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'type': type,
      'targetId': targetId,
      'read': false,
      'createdAt': DateTime.now(),
    });
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _inAppNotifications) {
      n['read'] = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _inAppNotifications.clear();
    notifyListeners();
  }
}
