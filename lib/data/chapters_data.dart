import '../models/models.dart';

/// Static data for all chapters in the book
class ChaptersData {
  ChaptersData._();

  /// List of all chapters with their sub-chapters
  static const List<Chapter> chapters = [
    // === פרק א - הלכות גסיסה ופטירה ===
    Chapter(
      id: 'chapter_1',
      title: 'פרק א - הלכות גסיסה ופטירה',
      description: 'דיני הגוסס, רגע המיתה, והטיפול הראשוני בנפטר',
      order: 1,
      subChapters: [
        SubChapter(
          id: 'chapter_1_1',
          title: 'הלכות הגוסס',
          htmlFileName: 'chapter_1/gosses.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_1_2',
          title: 'קביעת רגע המוות',
          htmlFileName: 'chapter_1/death_moment.html',
          order: 2,
        ),
        SubChapter(
          id: 'chapter_1_3',
          title: 'הטיפול הראשוני בנפטר',
          htmlFileName: 'chapter_1/initial_care.html',
          order: 3,
        ),
      ],
    ),

    // === פרק ב - הלכות אנינות ===
    Chapter(
      id: 'chapter_2',
      title: 'פרק ב - הלכות אנינות',
      description: 'דיני האונן מרגע הפטירה עד הקבורה',
      order: 2,
      subChapters: [
        SubChapter(
          id: 'chapter_2_1',
          title: 'מיהו האונן',
          htmlFileName: 'chapter_2/who_is_onen.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_2_2',
          title: 'איסורי האונן',
          htmlFileName: 'chapter_2/onen_restrictions.html',
          order: 2,
        ),
      ],
    ),

    // === פרק ג - הלכות קבורה ===
    Chapter(
      id: 'chapter_3',
      title: 'פרק ג - הלכות קבורה',
      description: 'דיני הקבורה והלוויה',
      order: 3,
      subChapters: [
        SubChapter(
          id: 'chapter_3_1',
          title: 'מצוות הקבורה',
          htmlFileName: 'chapter_3/burial_mitzvah.html',
          order: 1,
        ),
        SubChapter(
          id: 'chapter_3_2',
          title: 'סדר הלוויה',
          htmlFileName: 'chapter_3/funeral_order.html',
          order: 2,
        ),
      ],
    ),

    // הוסף פרקים נוספים כאן...
  ];

  /// Get all sub-chapters as flat list
  static List<SubChapter> get allSubChapters {
    return chapters.expand((c) => c.subChapters).toList();
  }

  /// Get chapter by ID
  static Chapter? getChapterById(String id) {
    try {
      return chapters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get sub-chapter by ID (searches all chapters)
  static SubChapter? getSubChapterById(String subId) {
    for (final chapter in chapters) {
      final sub = chapter.getSubChapterById(subId);
      if (sub != null) return sub;
    }
    return null;
  }

  /// Get parent chapter of a sub-chapter
  static Chapter? getParentChapter(String subChapterId) {
    for (final chapter in chapters) {
      if (chapter.subChapters.any((s) => s.id == subChapterId)) {
        return chapter;
      }
    }
    return null;
  }

  /// Get next sub-chapter
  static SubChapter? getNextSubChapter(String currentSubId) {
    final allSubs = allSubChapters;
    final currentIndex = allSubs.indexWhere((s) => s.id == currentSubId);
    if (currentIndex == -1 || currentIndex >= allSubs.length - 1) {
      return null;
    }
    return allSubs[currentIndex + 1];
  }

  /// Get previous sub-chapter
  static SubChapter? getPreviousSubChapter(String currentSubId) {
    final allSubs = allSubChapters;
    final currentIndex = allSubs.indexWhere((s) => s.id == currentSubId);
    if (currentIndex <= 0) {
      return null;
    }
    return allSubs[currentIndex - 1];
  }
}
