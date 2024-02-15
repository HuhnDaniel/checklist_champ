class Task {
  int id;
  String name;
  String description;
  int value;

  Task(this.id, this.name, this.description, this.value);

  factory Task.fromSqfliteDatabase(Map<String, dynamic> map) => Task(
        map['id'],
        map['name'] ?? '',
        map['description'] ?? '',
        map['value'].toInt() ?? 0,
      );
}
