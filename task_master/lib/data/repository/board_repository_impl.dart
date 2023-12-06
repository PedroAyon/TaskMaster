import 'dart:convert';

import 'package:task_master/domain/model/board.dart';
import 'package:task_master/domain/repository/board_repository.dart';
import 'package:http/http.dart' as http;
import 'package:task_master/util/utils.dart';
import '../../presentation/RepositoryManager.dart';
import '../../util/constants.dart';

class BoardRepositoryImpl implements BoardRepository {
  final String _boardURL = '$baseURL/board';

  @override
  Future<String?> createBoard(int workspaceId, String name) async {
    Map<String, String> data = {
      'workspace_id': workspaceId.toString(),
      'name': name
    };
    final response = await http.post(Uri.parse(_boardURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<String?> deleteBoard(int boardId) async {
    Map<String, String> data = {'board_id': boardId.toString()};
    final response = await http.delete(Uri.parse(_boardURL),
        body: data, headers: await _headers());
    if (response.statusCode.isStatusOk()) return null;
    return json.decode(response.body)['message'];
  }

  @override
  Future<List<Board>> getAllBoards(int workspaceId) async {
    Map<String, String> data = {'workspace_id': workspaceId.toString()};
    final response = await http.get(Uri.http(domain, '/board/all', data),
        headers: await _headers());
    Iterable responseBody = json.decode(response.body);
    List<Board> boards =
        List<Board>.from(responseBody.map((model) => Board.fromJson(model)));
    return boards;
  }

  @override
  Future<Board> getBoard(int workspaceId, int boardId) {
    // TODO: implement getBoard
    throw UnimplementedError();
  }

  Future<Map<String, String>> _headers() async {
    return {
      'taskmaster-access-token':
          await RepositoryManager().authRepository.getJWT() ?? '',
    };
  }
}
