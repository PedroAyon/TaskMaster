import 'dart:convert';

import 'package:task_master/domain/model/member_details.dart';
import 'package:task_master/domain/model/task.dart';
import 'package:http/http.dart' as http;
import 'package:task_master/domain/repository/task_assignment_repository.dart';
import 'package:task_master/util/utils.dart';
import '../../presentation/RepositoryManager.dart';
import '../../util/constants.dart';

class TaskAssignmentRepositoryImpl implements TaskAssignmentRepository {
  @override
  Future<String?> absolveTaskToMember(
      int taskId, int userId, int workspaceId) async {
    Map<String, String> data = {
      'user_id': userId.toString(),
      'workspace_id': workspaceId.toString(),
      'task_id': taskId.toString()
    };
    final response = await http.delete(Uri.parse('$baseURL/task/absolve'),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> assignTaskToMember(
      int taskId, int userId, int workspaceId) async {
    Map<String, String> data = {
      'user_id': userId.toString(),
      'workspace_id': workspaceId.toString(),
      'task_id': taskId.toString()
    };
    final response = await http.post(Uri.parse('$baseURL/task/assign'),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<List<MemberDetails>> getMembersAssignedToTask(int taskId) async {
    Map<String, String> data = {'task_id': taskId.toString()};
    final response = await http.get(
        Uri.http(domain, '/assigned_tasks/members', data),
        headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<MemberDetails> members = List<MemberDetails>.from(
        responseBody.map((model) => MemberDetails.fromJson(model)));
    return members;
  }

  @override
  Future<List<Task>> getTasksAssignedToMember(
      int workspaceId, int? boardId, int? userId) async {
    Map<String, String> data = {'workspace_id': workspaceId.toString()};
    if (userId != null) data['user_id'] = userId.toString();
    if (boardId != null) data['board_id'] = boardId.toString();
    final response = await http.get(
        Uri.http(domain, '/assigned_tasks/tasks', data),
        headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<Task> tasks =
        List<Task>.from(responseBody.map((model) => Task.fromJson(model)));
    return tasks;
  }

  Future<Map<String, String>> _headers() async {
    return {
      'taskmaster-access-token':
          await RepositoryManager().authRepository.getJWT() ?? '',
    };
  }
}
