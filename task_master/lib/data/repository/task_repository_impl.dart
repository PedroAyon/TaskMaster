import 'dart:convert';

import 'package:task_master/domain/model/task.dart';
import 'package:http/http.dart' as http;
import 'package:task_master/domain/repository/task_repository.dart';
import 'package:task_master/util/utils.dart';
import '../../presentation/RepositoryManager.dart';
import '../../util/constants.dart';

class TaskRepositoryImpl implements TaskRepository {
  final String _taskURL = '$baseURL/task';

  @override
  Future<String?> createTask(Task task) async{
    Map<String, String> data = {'list_id': task.listId.toString(), 'title': task.title};
    if (task.description != null) data['description'] = task.description!;
    if (task.dueDate != null) data['due_date'] = task.dueDate.toString();
    final response = await http.post(Uri.parse(_taskURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> deleteTask(int taskId) async {
    Map<String, String> data = {'id': taskId.toString()};
    final response = await http.delete(Uri.parse(_taskURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<List<Task>> getAllTasks(int boardId) async {
    Map<String, String> data = {'board_id': boardId.toString()};
    final response = await http.get(Uri.http(domain, '/task/board/all', data),
        headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<Task> tasks =
    List<Task>.from(responseBody.map((model) => Task.fromJson(model)));
    return tasks;
  }

  @override
  Future<List<Task>> getTasks(int listId) async {
    Map<String, String> data = {'list_id': listId.toString()};
    final response = await http.get(Uri.http(domain, '/list/all', data),
        headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<Task> tasks =
    List<Task>.from(responseBody.map((model) => Task.fromJson(model)));
    return tasks;
  }

  @override
  Future<String?> moveTaskToList(int taskId, int listId) async {
    Map<String, String> data = {'id': taskId.toString(), 'list_id': listId.toString()};
    final response = await http.post(Uri.parse('$_taskURL/move'),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> updateTask(Task task) async {
    Map<String, String> data = {'id' : task.id.toString(), 'title': task.title};
    if (task.description != null) data['description'] = task.description!;
    if (task.dueDate != null) data['due_date'] = task.dueDate.toString();
    final response = await http.put(Uri.parse(_taskURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  Future<Map<String, String>> _headers() async {
    return {
      'taskmaster-access-token':
      await RepositoryManager().authRepository.getJWT() ?? '',
    };
  }
}