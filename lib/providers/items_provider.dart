import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../models/item_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// ViewModel for lost/found items management.
class ItemsProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<ItemModel> _allItems = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  String _selectedType = 'all'; // 'all' | 'lost' | 'found'
  String _searchQuery = '';

  List<ItemModel> get allItems => _allItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  List<ItemModel> get filteredItems {
    return _allItems.where((item) {
      final matchType = _selectedType == 'all' || item.type == _selectedType;
      final matchCat = _selectedCategory == 'all' ||
          item.category == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.location.name.toLowerCase().contains(q);
      return matchType && matchCat && matchSearch && item.isActive;
    }).toList();
  }

  List<ItemModel> get lostItems =>
      filteredItems.where((i) => i.isLost).toList();

  List<ItemModel> get foundItems =>
      filteredItems.where((i) => i.isFound).toList();

  /// Start watching items via real-time stream.
  void startWatching() async {
    // Initial fetch if mock, otherwise stream will fill it
    if (AppConfig.useMockData) {
      _allItems = await FirestoreService.instance.getItems();
      notifyListeners();
    }

    FirestoreService.instance.watchItems().listen(
      (items) {
        _allItems = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void filterByCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void filterByType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'all';
    _selectedType = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  Future<bool> addItem({
    required String title,
    required String description,
    required String category,
    required String type,
    required ItemLocation location,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    List<File> photoFiles = const [],
    bool requiresValidation = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = _uuid.v4();

      // Upload photos first
      final photoUrls = <String>[];
      for (final file in photoFiles) {
        final url =
            await StorageService.instance.uploadItemPhoto(file, id);
        photoUrls.add(url);
      }

      final item = ItemModel(
        id: id,
        title: title,
        description: description,
        category: category,
        type: type,
        status: requiresValidation ? 'pending' : 'active',
        photos: photoUrls,
        location: location,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.instance.addItem(item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsResolved(String itemId) async {
    try {
      final item = _allItems.firstWhere((i) => i.id == itemId);
      await FirestoreService.instance.updateItem(
        item.copyWith(status: 'resolved', updatedAt: DateTime.now()),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveItem(String itemId) async {
    try {
      ItemModel item;
      try {
        item = _allItems.firstWhere((i) => i.id == itemId);
      } catch (_) {
        final pending = await FirestoreService.instance.getPendingItems();
        item = pending.firstWhere((i) => i.id == itemId);
      }

      await FirestoreService.instance.updateItem(
        item.copyWith(status: 'active', updatedAt: DateTime.now()),
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectItem(String itemId) async {
    try {
      await FirestoreService.instance.deleteItem(itemId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    try {
      await FirestoreService.instance.deleteItem(itemId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<ItemModel> getUserItems(String uid) =>
      _allItems.where((i) => i.userId == uid).toList();

  List<ItemModel> getPendingItems() =>
      _allItems.where((i) => i.status == 'pending').toList();

  List<ItemModel> getResolvedItems() =>
      _allItems.where((i) => i.status == 'resolved').toList();

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
