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

    final lastPosition = _storage.getLastReadingPosition();
    if (lastPosition != null) {
      _currentChapter = ChaptersData.getChapterById(lastPosition.chapterId);
      _currentScrollPosition = lastPosition.scrollPosition;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Open a chapter
  void openChapter(Chapter chapter, {double scrollPosition = 0}) {
    _currentChapter = chapter;
    _currentScrollPosition = scrollPosition;
    _saveCurrentPosition();
    notifyListeners();
  }

  /// Update scroll position
  void updateScrollPosition(double position) {
    _currentScrollPosition = position;
    _saveCurrentPosition();
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
}
