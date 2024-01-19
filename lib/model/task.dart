class Task {
  String name;
  String description;
  int value;

  Task(this.name, this.description, this.value);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'value': value,
    };
  }
}
