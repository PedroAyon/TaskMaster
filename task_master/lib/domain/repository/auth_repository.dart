abstract class AuthRepository {
  Future<bool> logIn(String email, String password);
  Future<void> saveJWT(String jwt);
  Future<bool> signUp(String name, String email, String password);
}
