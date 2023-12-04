import '../model/user.dart';

abstract class AuthRepository {
  Future<String?> logIn(String email, String password);
  Future<void> saveJWT(String jwt);
  Future<String?> getJWT();
  Future<void> logOut(); // Delete JWT
  Future<String?> signUp(String name, String email, String password);
  Future<bool> userLoggedIn();
  Future<User?> getUser();
}
