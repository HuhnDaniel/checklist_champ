class Task {
  String name;
  String description;
  int value;

  Task(this.name, this.description, this.value);

  factory Task.fromSqfliteDatabase(Map<String, dynamic> map) => Task(
        map['name'] ?? '',
        map['description'] ?? '',
        map['value'].toInt() ?? 0,
      );
}
