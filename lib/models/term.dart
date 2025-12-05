import 'package:hive/hive.dart';

part 'term.g.dart';

/// Represents a term/concept in the glossary
class Term {
  final String id;
  final String title;
  final String htmlFileName;
  final String? description;

  const Term({
    required this.id,
    required this.title,
    required this.htmlFileName,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Term && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Term(id: $id, title: $title)';
}

/// Hive adapter for storing term access history
@HiveType(typeId: 3)
class TermAccess extends HiveObject {
  @HiveField(0)
  final String termId;

  @HiveField(1)
  final DateTime accessedAt;

  TermAccess({
    required this.termId,
    required this.accessedAt,
  });
}
