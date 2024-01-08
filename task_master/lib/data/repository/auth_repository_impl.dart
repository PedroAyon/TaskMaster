import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:localstorage/localstorage.dart';
import 'package:task_master/domain/model/user.dart';
import 'package:task_master/domain/repository/auth_repository.dart';
import 'package:task_master/util/constants.dart';
import 'package:http/http.dart' as http;
import 'package:task_master/util/utils.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorage _storage = LocalStorage('auth');
  final _logInURL = '$baseURL/login';
  final _signUpURL = '$baseURL/signup';
  final _userURL = '$baseURL/user';

  @override
  Future<String?> logIn(String email, String password) async {
    var data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    final response = await http.post(Uri.parse(_logInURL), body: data);
    var responseBody = json.decode(response.body);
    if (!response.statusCode.isStatusOk()) return responseBody['message'];
    await saveJWT(responseBody['token']);
    return null;
  }

  @override
  Future<void> saveJWT(String jwt) async {
    await _storage.ready;
    _storage.setItem('jwt', jwt);
  }

  @override
  Future<String?> signUp(String name, String email, String password) async {
    var data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['password'] = password;
    final response = await http.post(Uri.parse(_signUpURL), body: data);
    if (!response.statusCode.isStatusOk()) {
      var responseBody = json.decode(response.body);
      return responseBody['message'];
    }
    return null;
  }

  @override
  Future<String?> getJWT() async {
    await _storage.ready;
    return _storage.getItem('jwt');
  }

  @override
  Future<void> logOut() async {
    await _storage.ready;
    _storage.deleteItem('jwt');
  }

  @override
  Future<bool> userLoggedIn() async {
    return await getJWT() != null;
  }

  @override
  Future<User?> getUser() async {
    if (!await userLoggedIn()) return null;
    final response = await http.get(Uri.parse(_userURL),
        headers: {'taskmaster-access-token': await getJWT() ?? ''});
    return User.fromJson(json.decode(response.body));
  }
}
