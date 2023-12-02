import '../model/board_list.dart';

abstract class BoardListRepository {
  Future<List<BoardList>> getAllBoards(int workspaceId);
}