import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:task_master/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  @override
  Future<bool> logIn(String email, String password) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<void> saveJWT(String jwt) async {
    await _storage.write(key: 'jwt', value: jwt);
  }

  @override
  Future<bool> signUp(String name, String email, String password) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<String?> getJWT() async {
    return await _storage.read(key: 'jwt');
  }

  @override
  Future<void> logOut() async {
    await _storage.delete(key: 'jwt');
  }
}
