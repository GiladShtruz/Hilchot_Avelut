import 'package:hive/hive.dart';

part 'reading_position.g.dart';

/// Stores the last reading position for resuming later
@HiveType(typeId: 1)
class ReadingPosition extends HiveObject {
  @HiveField(0)
  final String chapterId;

  @HiveField(1)
  final double scrollPosition;

  @HiveField(2)
  final DateTime updatedAt;

  ReadingPosition({
    required this.chapterId,
    required this.scrollPosition,
    required this.updatedAt,
  });

  /// Creates a copy with updated fields
  ReadingPosition copyWith({
    String? chapterId,
    double? scrollPosition,
    DateTime? updatedAt,
  }) {
    return ReadingPosition(
      chapterId: chapterId ?? this.chapterId,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ReadingPosition(chapter: $chapterId, scroll: $scrollPosition)';
}
