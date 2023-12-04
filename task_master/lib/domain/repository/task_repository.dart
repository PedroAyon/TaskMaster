import '../model/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(int listId);
  Future<List<Task>> getAllTasks(int boardId);
  Future<String?> createTask(Task task);
  Future<String?> updateTask(Task task);
  Future<String?> deleteTask(int taskId);
  Future<String?> moveTaskToList(int taskId, int listId);
}