import '../model/board.dart';

abstract class BoardRepository{
  Future<List<Board>> getAllBoards(int workspaceId);
  Future<Board> getBoard(int workspaceId, int boardId);
  Future<String?> createBoard(int workspaceId, String name);
  Future<String?> deleteBoard(int boardId);
}