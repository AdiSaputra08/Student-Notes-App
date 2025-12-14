class Task {
  String id;
  String title;
  String description;
  String category;
  DateTime dateCreated;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateCreated,
  });

  // Convert object ke Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  // Convert Map kembali ke object
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      dateCreated: DateTime.parse(map['dateCreated']),
    );
  }
}