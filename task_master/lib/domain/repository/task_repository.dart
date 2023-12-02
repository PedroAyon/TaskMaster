import '../model/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(int listId);
  Future<Task> getAllTasks(int boardId);
  Future<bool> createTask(Task task);
  Future<bool> updateTask(Task task);
  Future<bool> deleteTask(int taskId);
  Future<bool> moveTaskToList(int taskId, int listId);
}