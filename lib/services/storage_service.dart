import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/models.dart';

/// Service for managing local storage with Hive
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  late Box<Favorite> _favoritesBox;
  late Box<ReadingPosition> _readingPositionBox;
  late Box _settingsBox;

  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FavoriteAdapter());
    Hive.registerAdapter(ReadingPositionAdapter());

    // Open boxes
    _favoritesBox = await Hive.openBox<Favorite>(AppConstants.favoritesBox);
    _readingPositionBox =
        await Hive.openBox<ReadingPosition>(AppConstants.readingPositionBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);

    _isInitialized = true;
  }

  // ============ Favorites Methods ============

  /// Get all favorites sorted by creation date (newest first)
  List<Favorite> getAllFavorites() {
    final favorites = _favoritesBox.values.toList();
    favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return favorites;
  }

  /// Get favorites for a specific chapter
  List<Favorite> getFavoritesForChapter(String chapterId) {
    return _favoritesBox.values
        .where((f) => f.chapterId == chapterId)
        .toList();
  }

  /// Add a new favorite
  Future<void> addFavorite(Favorite favorite) async {
    await _favoritesBox.put(favorite.id, favorite);
  }

  /// Remove a favorite by ID
  Future<void> removeFavorite(String id) async {
    await _favoritesBox.delete(id);
  }

  /// Update a favorite
  Future<void> updateFavorite(Favorite favorite) async {
    await _favoritesBox.put(favorite.id, favorite);
  }

  /// Check if a position is favorited
  bool isFavorited(String chapterId, double scrollPosition) {
    return _favoritesBox.values.any(
      (f) =>
          f.chapterId == chapterId &&
          (f.scrollPosition - scrollPosition).abs() < 10,
    );
  }

  // ============ Reading Position Methods ============

  /// Save current reading position
  Future<void> saveReadingPosition(String chapterId, double scrollPosition) async {
    final position = ReadingPosition(
      chapterId: chapterId,
      scrollPosition: scrollPosition,
      updatedAt: DateTime.now(),
    );
    await _readingPositionBox.put('current', position);
  }

  /// Get last reading position
  ReadingPosition? getLastReadingPosition() {
    return _readingPositionBox.get('current');
  }

  /// Clear reading position
  Future<void> clearReadingPosition() async {
    await _readingPositionBox.delete('current');
  }

  // ============ Settings Methods ============

  /// Save a setting value
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting value
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // ============ Utility Methods ============

  /// Clear all data (for debugging/reset)
  Future<void> clearAll() async {
    await _favoritesBox.clear();
    await _readingPositionBox.clear();
    await _settingsBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _favoritesBox.close();
    await _readingPositionBox.close();
    await _settingsBox.close();
  }
}
