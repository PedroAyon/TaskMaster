import '../model/board_list.dart';

abstract class BoardListRepository {
  Future<List<BoardList>> getAllLists(int boardId);
  Future<bool> deleteList(int listId);
  Future<bool> changeName(int listId, String newName);
  Future<bool> createList(int boardId, String name);
}