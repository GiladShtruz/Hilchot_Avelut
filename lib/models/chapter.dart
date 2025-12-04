/// Represents a sub-chapter (actual HTML content)
class SubChapter {
  final String id;
  final String title;
  final String htmlFileName;
  final int order;

  const SubChapter({
    required this.id,
    required this.title,
    required this.htmlFileName,
    required this.order,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubChapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SubChapter(id: $id, title: $title)';
}

/// Represents a main chapter (folder) containing sub-chapters
class Chapter {
  final String id;
  final String title;
  final String? description;
  final int order;
  final List<SubChapter> subChapters;

  const Chapter({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    required this.subChapters,
  });

  /// Check if chapter has sub-chapters
  bool get hasSubChapters => subChapters.isNotEmpty;

  /// Get sub-chapter by ID
  SubChapter? getSubChapterById(String subId) {
    try {
      return subChapters.firstWhere((s) => s.id == subId);
    } catch (_) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Chapter(id: $id, title: $title, subChapters: ${subChapters.length})';
}
