import 'dart:convert';

import 'package:task_master/domain/model/board_list.dart';
import 'package:task_master/domain/repository/list_repository.dart';
import 'package:http/http.dart' as http;
import 'package:task_master/util/utils.dart';
import '../../presentation/RepositoryManager.dart';
import '../../util/constants.dart';

class ListRepositoryImpl implements ListRepository {
  final String _listURL = '$baseURL/list';

  @override
  Future<String?> changeName(int listId, String newName) async {
    Map<String, String> data = {'id': listId.toString(), 'new_name': newName};
    final response = await http.put(Uri.parse(_listURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> createList(int boardId, String name) async {
    Map<String, String> data = {'board_id': boardId.toString(), 'name': name};
    final response = await http.post(Uri.parse(_listURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> deleteList(int listId) async {
    Map<String, String> data = {'id': listId.toString()};
    final response = await http.post(Uri.parse(_listURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<List<BoardList>> getAllLists(int boardId) async {
    Map<String, String> data = {'board_id': boardId.toString()};
    final response = await http.get(Uri.http(domain, '/list/all', data),
        headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<BoardList> lists =
    List<BoardList>.from(responseBody.map((model) => BoardList.fromJson(model)));
    return lists;
  }

  Future<Map<String, String>> _headers() async {
    return {
      'taskmaster-access-token':
          await RepositoryManager().authRepository.getJWT() ?? '',
    };
  }
}
