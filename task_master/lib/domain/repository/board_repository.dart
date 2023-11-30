import '../model/board.dart';

abstract class BoardRepository{
  Future<List<Board>> getAllBoards(int workspaceId);
  Future<Board> getBoard(int workspaceId, int boardId);
  Future<bool> createBoard(Board board);
  Future<bool> deleteBoard(int boardId);
}