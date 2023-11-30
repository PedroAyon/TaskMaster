class Board {
  int? id;
  int workspaceId;
  String name;

  Board({this.id, required this.workspaceId, required this.name});

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      workspaceId: json['workspace_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'name': name,
    };
  }
}
