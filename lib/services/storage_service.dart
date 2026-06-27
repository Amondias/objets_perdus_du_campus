import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

/// Firebase Storage helper used by [ItemsProvider].
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadItemPhoto(XFile file, String itemId) async {
    try {
      final fileName = file.name;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final ref = _storage
          .ref()
          .child('item_photos')
          .child(itemId)
          .child('${timestamp}_$fileName');

      debugPrint('[StorageService] Lecture des octets pour $fileName...');
      final bytes = await file.readAsBytes();
      
      debugPrint('[StorageService] Envoi des données vers Firebase Storage...');
      
      // On Web, we must provide the content-type and use putData
      final uploadTask = ref.putData(
        bytes, 
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to progress to see if it's moving
      final progressSubscription = uploadTask.snapshotEvents.listen((event) {
        final progress = 100.0 * (event.bytesTransferred / event.totalBytes);
        debugPrint('[StorageService] Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      try {
        final snapshot = await uploadTask.timeout(
          const Duration(seconds: 120), // Double le temps pour les connexions lentes
          onTimeout: () {
            uploadTask.cancel();
            throw TimeoutException('L\'envoi de la photo a expiré. Vérifiez votre connexion ou la config CORS Firebase.');
          },
        );

        final url = await snapshot.ref.getDownloadURL();
        debugPrint('[StorageService] Upload réussi. URL : $url');
        return url;
      } finally {
        await progressSubscription.cancel();
      }
    } catch (e) {
      debugPrint('[StorageService] ERREUR critique : $e');
      rethrow;
    }
  }
}
