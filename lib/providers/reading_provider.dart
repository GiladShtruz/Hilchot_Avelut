import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../data/chapters_data.dart';

/// Provider for managing reading state and position
class ReadingProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  Chapter? _currentChapter;
  double _currentScrollPosition = 0;
  bool _isLoading = false;

  // Cache of scroll positions for each chapter
  final Map<String, double> _chapterPositions = {};

  /// Currently open chapter
  Chapter? get currentChapter => _currentChapter;

  /// Current scroll position
  double get currentScrollPosition => _currentScrollPosition;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Initialize and restore last reading position
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Load all saved chapter positions
    final allPositions = _storage.getAllChapterPositions();
    _chapterPositions.addAll(allPositions);

    // Load last reading position
    final lastPosition = _storage.getLastReadingPosition();
    if (lastPosition != null) {
      _currentChapter = ChaptersData.getChapterById(lastPosition.chapterId);
      _currentScrollPosition = lastPosition.scrollPosition;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get saved scroll position for a specific chapter
  double getChapterPosition(String chapterId) {
    return _chapterPositions[chapterId] ?? 0.0;
  }

  /// Save scroll position for a specific chapter
  Future<void> saveChapterPosition(String chapterId, double scrollPosition) async {
    _chapterPositions[chapterId] = scrollPosition;
    await _storage.saveChapterPosition(chapterId, scrollPosition);

    // Always update global last position for this chapter
    _currentScrollPosition = scrollPosition;
    _currentChapter = ChaptersData.getChapterById(chapterId);
    await _storage.saveReadingPosition(chapterId, scrollPosition);

    notifyListeners();
  }

  /// Open a chapter - retrieves saved position if available
  void openChapter(Chapter chapter, {double? scrollPosition}) {
    _currentChapter = chapter;

    // Use provided position, or saved position, or 0
    if (scrollPosition != null && scrollPosition > 0) {
      _currentScrollPosition = scrollPosition;
    } else {
      _currentScrollPosition = _chapterPositions[chapter.id] ?? 0.0;
    }

    _saveCurrentPosition();
    notifyListeners();
  }

  /// Update scroll position
  void updateScrollPosition(double position) {
    _currentScrollPosition = position;
    // Don't notify listeners for every scroll update to avoid performance issues
  }

  /// Save current position to storage
  Future<void> _saveCurrentPosition() async {
    if (_currentChapter != null) {
      await _storage.saveReadingPosition(
        _currentChapter!.id,
        _currentScrollPosition,
      );
    }
  }

  /// Go to next chapter
  bool goToNextChapter() {
    if (_currentChapter == null) return false;

    final next = ChaptersData.getNextChapter(_currentChapter!.id);
    if (next != null) {
      openChapter(next);
      return true;
    }
    return false;
  }

  /// Go to previous chapter
  bool goToPreviousChapter() {
    if (_currentChapter == null) return false;

    final previous = ChaptersData.getPreviousChapter(_currentChapter!.id);
    if (previous != null) {
      openChapter(previous);
      return true;
    }
    return false;
  }

  /// Close current chapter
  void closeChapter() {
    _currentChapter = null;
    _currentScrollPosition = 0;
    notifyListeners();
  }

  /// Check if there's a saved reading position
  bool get hasSavedPosition {
    return _storage.getLastReadingPosition() != null;
  }

  /// Get saved reading position info
  ReadingPosition? get savedPosition {
    return _storage.getLastReadingPosition();
  }

  /// Check if a chapter has a saved position
  bool hasChapterPosition(String chapterId) {
    return _chapterPositions.containsKey(chapterId) &&
        _chapterPositions[chapterId]! > 0;
  }
}
