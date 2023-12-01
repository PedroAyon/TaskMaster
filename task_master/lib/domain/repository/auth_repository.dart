abstract class AuthRepository {
  Future<bool> logIn(String email, String password);
  Future<void> saveJWT(String jwt);
  Future<String?> getJWT();
  Future<void> logOut(); // Delete JWT
  Future<bool> signUp(String name, String email, String password);
}
