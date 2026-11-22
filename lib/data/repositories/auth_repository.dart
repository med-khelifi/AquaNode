/// Repository handling authentication.
class AuthRepository {
  Future<String?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (password == 'wrong123') return 'Incorrect email or password.';
    return null;
  }
}
