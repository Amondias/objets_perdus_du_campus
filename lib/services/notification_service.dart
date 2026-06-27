import 'package:firebase_messaging/firebase_messaging.dart';

/// Thin wrapper around Firebase Cloud Messaging.
///
/// Note: this project already uses [NotificationProvider] to manage in-app
/// notifications list.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Basic permission request (no-op on web).
    await _messaging.requestPermission();

    // Keep this minimal: the provider maintains in-app state.
    // Background/foreground handlers can be added later.
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    return token;
  }
}

