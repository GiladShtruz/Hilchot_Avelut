import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../data/chapters_data.dart';

/// Provider for managing reading state and position
class ReadingProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  SubChapter? _currentSubChapter;
  double _currentScrollPosition = 0;
  bool _isLoading = false;

  // Cache of scroll positions for each sub-chapter
  final Map<String, double> _chapterPositions = {};

  /// Currently open sub-chapter
  SubChapter? get currentSubChapter => _currentSubChapter;

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
      _currentSubChapter = ChaptersData.getSubChapterById(lastPosition.chapterId);
      _currentScrollPosition = lastPosition.scrollPosition;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get saved scroll position for a specific sub-chapter
  double getChapterPosition(String subChapterId) {
    return _chapterPositions[subChapterId] ?? 0.0;
  }

  /// Save scroll position for a specific sub-chapter
  Future<void> saveChapterPosition(String subChapterId, double scrollPosition) async {
    _chapterPositions[subChapterId] = scrollPosition;
    await _storage.saveChapterPosition(subChapterId, scrollPosition);

    // Always update global last position
    _currentScrollPosition = scrollPosition;
    _currentSubChapter = ChaptersData.getSubChapterById(subChapterId);
    await _storage.saveReadingPosition(subChapterId, scrollPosition);
    
    notifyListeners();
  }

  /// Open a sub-chapter - retrieves saved position if available
  void openSubChapter(SubChapter subChapter, {double? scrollPosition}) {
    _currentSubChapter = subChapter;
    
    // Use provided position, or saved position, or 0
    if (scrollPosition != null && scrollPosition > 0) {
      _currentScrollPosition = scrollPosition;
    } else {
      _currentScrollPosition = _chapterPositions[subChapter.id] ?? 0.0;
    }
    
    _saveCurrentPosition();
    notifyListeners();
  }

  /// Save current position to storage
  Future<void> _saveCurrentPosition() async {
    if (_currentSubChapter != null) {
      await _storage.saveReadingPosition(
        _currentSubChapter!.id,
        _currentScrollPosition,
      );
    }
  }

  /// Go to next sub-chapter
  bool goToNextSubChapter() {
    if (_currentSubChapter == null) return false;

    final next = ChaptersData.getNextSubChapter(_currentSubChapter!.id);
    if (next != null) {
      openSubChapter(next);
      return true;
    }
    return false;
  }

  /// Go to previous sub-chapter
  bool goToPreviousSubChapter() {
    if (_currentSubChapter == null) return false;

    final previous = ChaptersData.getPreviousSubChapter(_currentSubChapter!.id);
    if (previous != null) {
      openSubChapter(previous);
      return true;
    }
    return false;
  }

  /// Close current sub-chapter
  void closeSubChapter() {
    _currentSubChapter = null;
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

  /// Check if a sub-chapter has a saved position
  bool hasChapterPosition(String subChapterId) {
    return _chapterPositions.containsKey(subChapterId) && 
           _chapterPositions[subChapterId]! > 0;
  }
}
