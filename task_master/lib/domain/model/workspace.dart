class Workspace {
  int? id;
  String name;
  int createdBy;

  Workspace({this.id, required this.name, required this.createdBy});

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
    };
  }
}
