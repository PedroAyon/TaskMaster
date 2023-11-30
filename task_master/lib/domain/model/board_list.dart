class BoardList {
  int id;
  String name;
  int boardId;

  BoardList({required this.id, required this.name, required this.boardId});

  factory BoardList.fromJson(Map<String, dynamic> json) {
    return BoardList(
      id: json['id'],
      name: json['name'],
      boardId: json['board_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'board_id': boardId,
    };
  }
}
