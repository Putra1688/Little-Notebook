class Idea {
  final String text;
  final DateTime createdAt;

  Idea({
    this.text = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
