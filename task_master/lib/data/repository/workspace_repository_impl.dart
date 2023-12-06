import 'dart:convert';
import 'dart:io';

import 'package:task_master/domain/model/member_details.dart';
import 'package:task_master/domain/model/workspace.dart';
import 'package:task_master/domain/repository/workspace_repository.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/util/constants.dart';
import 'package:http/http.dart' as http;
import 'package:task_master/util/utils.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final String _workspaceURL = '$baseURL/workspace';

  @override
  Future<String?> addMemberToWorkspace(
      int workspaceId, String email, String role) async {
    Map<String, String> data = {'workspace_id': workspaceId.toString(), 'email': email, 'role': role};
    final response = await http.post(Uri.parse('$_workspaceURL/add_member'),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> changeMemberRole(
      int workspaceId, int userId, String role) async {
    Map<String, String> data = {
      'workspace_id': workspaceId.toString(),
      'user_id': userId.toString(),
      'new_role': role
    };
    final response = await http.put(
        Uri.parse('$_workspaceURL/change_member_role'),
        body: data,
        headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> createWorkspace(String name) async {
    Map<String, String> data = {'name': name};
    final response = await http.post(Uri.parse(_workspaceURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> deleteWorkspace(int workspaceId) async {
    Map<String, String> data = {'id': workspaceId.toString()};
    final response = await http.delete(Uri.parse(_workspaceURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<List<Workspace>> getWorkspaceList() async {
    final response =
        await http.get(Uri.parse(_workspaceURL), headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<Workspace> workspaces = List<Workspace>.from(
        responseBody.map((model) => Workspace.fromJson(model)));
    return workspaces;
  }

  @override
  Future<List<MemberDetails>> getWorkspaceMembers(int workspaceId) async {
    Map<String, String> data = {'id': workspaceId.toString()};
    final response = await http.get(
        Uri.parse('$_workspaceURL/members').replace(queryParameters: data),
        headers: await _headers());
    if (!response.statusCode.isStatusOk()) {
      return json.decode(response.body)['message'];
    }
    Iterable responseBody = json.decode(response.body);
    List<MemberDetails> members = List<MemberDetails>.from(
        responseBody.map((model) => MemberDetails.fromJson(model)));
    return members;
  }

  @override
  Future<String?> removeMemberFromWorkspace(int workspaceId, int userId) async {
    Map<String, String> data = {'workspace_id': workspaceId.toString(), 'user_id': userId.toString()};
    final response = await http.delete(
        Uri.parse('$_workspaceURL/delete_member'),
        body: data,
        headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String> getUserRole(int workspaceId, int? userId) async {
    Map<String, String> data = {'workspace_id': workspaceId.toString()};
    if (userId != null) data['user_id'] = userId.toString();
    final response = await http.get(
        Uri.http(domain, '/workspace/get_user_role', data),
        headers: await _headers());
    final responseBody = json.decode(response.body);
    if (!response.statusCode.isStatusOk()) return responseBody['message'];
    return responseBody['role'];
  }

  Future<Map<String, String>> _headers() async {
    return {
      'taskmaster-access-token':
          await RepositoryManager().authRepository.getJWT() ?? '',
    };
  }

  @override
  Future<String?> renameWorkspace(int workspaceId, String newName) async {
    Map<String, String> data = {'id': workspaceId.toString(), 'new_name': newName};
    final response = await http.put(Uri.parse('$_workspaceURL/rename'),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }
}
