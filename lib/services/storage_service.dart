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
  late Box<double> _chapterPositionsBox;
  late Box<DateTime> _termAccessBox;

  bool _isInitialized = false;

  static const String _chapterPositionsBoxName = 'chapter_positions';
  static const String _termAccessBoxName = 'term_access';

  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FavoriteAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ReadingPositionAdapter());
    }

    // Open boxes
    _favoritesBox = await Hive.openBox<Favorite>(AppConstants.favoritesBox);
    _readingPositionBox =
        await Hive.openBox<ReadingPosition>(AppConstants.readingPositionBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _chapterPositionsBox = await Hive.openBox<double>(_chapterPositionsBoxName);
    _termAccessBox = await Hive.openBox<DateTime>(_termAccessBoxName);

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

  // ============ Chapter Position Methods ============

  /// Save scroll position for a specific chapter
  Future<void> saveChapterPosition(String chapterId, double scrollPosition) async {
    await _chapterPositionsBox.put(chapterId, scrollPosition);
  }

  /// Get scroll position for a specific chapter
  double getChapterPosition(String chapterId) {
    return _chapterPositionsBox.get(chapterId) ?? 0.0;
  }

  /// Get all saved chapter positions
  Map<String, double> getAllChapterPositions() {
    final positions = <String, double>{};
    for (final key in _chapterPositionsBox.keys) {
      positions[key as String] = _chapterPositionsBox.get(key) ?? 0.0;
    }
    return positions;
  }

  // ============ Reading Position Methods ============

  /// Save current reading position (last opened chapter)
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

  // ============ Term Access Methods ============

  /// Record access to a term
  Future<void> recordTermAccess(String termId) async {
    await _termAccessBox.put(termId, DateTime.now());
  }

  /// Get term access history (termId -> last access time)
  Map<String, DateTime> getTermAccessHistory() {
    final history = <String, DateTime>{};
    for (final key in _termAccessBox.keys) {
      final value = _termAccessBox.get(key);
      if (value != null) {
        history[key as String] = value;
      }
    }
    return history;
  }

  // ============ Utility Methods ============

  /// Clear all data (for debugging/reset)
  Future<void> clearAll() async {
    await _favoritesBox.clear();
    await _readingPositionBox.clear();
    await _settingsBox.clear();
    await _chapterPositionsBox.clear();
    await _termAccessBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _favoritesBox.close();
    await _readingPositionBox.close();
    await _settingsBox.close();
    await _chapterPositionsBox.close();
    await _termAccessBox.close();
  }
}
