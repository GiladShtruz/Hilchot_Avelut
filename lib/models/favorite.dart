import 'package:hive/hive.dart';

part 'favorite.g.dart';

/// Represents a saved favorite/bookmark with scroll position
@HiveType(typeId: 0)
class Favorite extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chapterId;

  @HiveField(2)
  final String chapterTitle;

  @HiveField(3)
  final double scrollPosition;

  @HiveField(4)
  final String? textPreview;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  String? customTitle;

  Favorite({
    required this.id,
    required this.chapterId,
    required this.chapterTitle,
    required this.scrollPosition,
    this.textPreview,
    required this.createdAt,
    this.customTitle,
  });

  /// Display title - custom title if set, otherwise chapter title
  String get displayTitle => customTitle ?? chapterTitle;

  /// Creates a copy with updated fields
  Favorite copyWith({
    String? id,
    String? chapterId,
    String? chapterTitle,
    double? scrollPosition,
    String? textPreview,
    DateTime? createdAt,
    String? customTitle,
  }) {
    return Favorite(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      textPreview: textPreview ?? this.textPreview,
      createdAt: createdAt ?? this.createdAt,
      customTitle: customTitle ?? this.customTitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Favorite(id: $id, chapter: $chapterTitle, scroll: $scrollPosition)';
}
