class ChecklistItem {
  int taskId;
  int itemNumber;
  bool completed;
  String description;

  ChecklistItem({required this.taskId, required this.itemNumber, required this.completed, required this.description});

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      taskId: json['task_id'],
      itemNumber: json['item_number'],
      completed: json['completed'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'item_number': itemNumber,
      'completed': completed,
      'description': description,
    };
  }
}
