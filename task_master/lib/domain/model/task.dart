class Task {
  int? id;
  int listId;
  String title;
  String? description;
  DateTime? dueDate;

  Task({this.id, required this.listId, required this.title, this.description, this.dueDate});

  factory Task.fromJson(Map<String, dynamic> json) {
    Task task = Task(
      id: json['id'],
      listId: json['list_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'] != null? DateTime.parse(json['due_date']) : null,
    );
    print(task.dueDate);
    return task;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list_id': listId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}
