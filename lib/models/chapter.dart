/// Represents a chapter/section in the book
class Chapter {
  final String id;
  final String title;
  final String htmlFileName;
  final String? description;
  final int order;

  const Chapter({
    required this.id,
    required this.title,
    required this.htmlFileName,
    this.description,
    required this.order,
  });

  /// Creates a Chapter from a map (for JSON parsing)
  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as String,
      title: map['title'] as String,
      htmlFileName: map['htmlFileName'] as String,
      description: map['description'] as String?,
      order: map['order'] as int,
    );
  }

  /// Converts the Chapter to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'htmlFileName': htmlFileName,
      'description': description,
      'order': order,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Chapter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Chapter(id: $id, title: $title)';
}
