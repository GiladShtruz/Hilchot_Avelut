import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Provider for managing favorites state
class FavoritesProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  List<Favorite> _favorites = [];
  bool _isLoading = false;

  /// All favorites
  List<Favorite> get favorites => _favorites;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Number of favorites
  int get count => _favorites.length;

  /// Initialize and load favorites
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _favorites = _storage.getAllFavorites();

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new favorite
  Future<void> addFavorite({
    required String chapterId,
    required String chapterTitle,
    required double scrollPosition,
    String? textPreview,
    String? customTitle,
  }) async {
    final favorite = Favorite(
      id: '${chapterId}_${DateTime.now().millisecondsSinceEpoch}',
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      scrollPosition: scrollPosition,
      textPreview: textPreview,
      createdAt: DateTime.now(),
      customTitle: customTitle,
    );

    await _storage.addFavorite(favorite);
    _favorites = _storage.getAllFavorites();
    notifyListeners();
  }

  /// Remove a favorite
  Future<void> removeFavorite(String id) async {
    await _storage.removeFavorite(id);
    _favorites = _storage.getAllFavorites();
    notifyListeners();
  }

  /// Update favorite's custom title
  Future<void> updateFavoriteTitle(String id, String newTitle) async {
    final index = _favorites.indexWhere((f) => f.id == id);
    if (index == -1) return;

    final updated = _favorites[index].copyWith(customTitle: newTitle);
    await _storage.updateFavorite(updated);
    _favorites = _storage.getAllFavorites();
    notifyListeners();
  }

  /// Check if position is favorited
  bool isFavorited(String chapterId, double scrollPosition) {
    return _storage.isFavorited(chapterId, scrollPosition);
  }

  /// Get favorites for a specific chapter
  List<Favorite> getFavoritesForChapter(String chapterId) {
    return _favorites.where((f) => f.chapterId == chapterId).toList();
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    for (final favorite in _favorites) {
      await _storage.removeFavorite(favorite.id);
    }
    _favorites = [];
    notifyListeners();
  }
}
