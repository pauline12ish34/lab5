class Post {
  final int? id;
  final String title;
  final String content;
  final String author;
  final String createdAt;

  Post({
    this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  // Convert a Post object into a Map for SQLite insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'createdAt': createdAt,
    };
  }

  // Create a Post object from a Map (from SQLite query result)
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      author: map['author'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
    );
  }

  // Create a copy of this Post with optional new values
  Post copyWith({
    int? id,
    String? title,
    String? content,
    String? author,
    String? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Post{id: $id, title: $title, author: $author, createdAt: $createdAt}';
  }
}
