import 'package:flutter/foundation.dart';

/// App-local mock data seeding.
///
/// In the original project, this probably created in-memory data matching
/// providers. In this reconstructed codebase, we only keep a small
/// “seed” that enables UI development without external dependencies.
///
/// When Firebase is configured, you can set [useMockData] to false and the
/// app will rely on real backend.
class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  /// Seed mock state.
  void seedData() {
    // Providers in this repo already fetch/watch through services.
    // So for a minimal working implementation we simply do nothing here.
    // (You can extend later by plugging a mock FirestoreService.)
    debugPrint('[MockDataService] seedData() called');
  }
}

