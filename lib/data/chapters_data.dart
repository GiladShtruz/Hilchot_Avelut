import '../models/models.dart';

/// Static data for all chapters in the book
class ChaptersData {
  ChaptersData._();

  /// List of all chapters
  /// Add new chapters here when adding new HTML files
  static const List<Chapter> chapters = [
    Chapter(
      id: 'chapter_1',
      title: 'פרק א - הלכות גסיסה ופטירה',
      htmlFileName: 'chapter_1.html',
      description: 'דיני הגוסס, רגע המיתה, והטיפול הראשוני בנפטר',
      order: 1,
    ),
    // הוסף פרקים נוספים כאן:
    // Chapter(
    //   id: 'chapter_2',
    //   title: 'פרק ב - ...',
    //   htmlFileName: 'chapter_2.html',
    //   description: '...',
    //   order: 2,
    // ),
  ];

  /// Get chapter by ID
  static Chapter? getChapterById(String id) {
    try {
      return chapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get chapter by HTML file name
  static Chapter? getChapterByFileName(String fileName) {
    try {
      return chapters.firstWhere((c) => c.htmlFileName == fileName);
    } catch (_) {
      return null;
    }
  }

  /// Get next chapter
  static Chapter? getNextChapter(String currentId) {
    final current = getChapterById(currentId);
    if (current == null) return null;

    try {
      return chapters.firstWhere((c) => c.order == current.order + 1);
    } catch (_) {
      return null;
    }
  }

  /// Get previous chapter
  static Chapter? getPreviousChapter(String currentId) {
    final current = getChapterById(currentId);
    if (current == null) return null;

    try {
      return chapters.firstWhere((c) => c.order == current.order - 1);
    } catch (_) {
      return null;
    }
  }
}
