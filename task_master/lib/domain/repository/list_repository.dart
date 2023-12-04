import '../model/board_list.dart';

abstract class ListRepository {
  Future<List<BoardList>> getAllLists(int boardId);
  Future<String?> deleteList(int listId);
  Future<String?> changeName(int listId, String newName);
  Future<String?> createList(int boardId, String name);
}