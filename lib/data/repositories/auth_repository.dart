import 'package:firebase_auth/firebase_auth.dart';
import 'package:aqua_node/core/services/firebase/firebase.dart';

/// Repository handling authentication with Firebase Auth.
class AuthRepository {
  final FirebaseService? _firebaseService;

  AuthRepository({FirebaseService? firebaseService})
      : _firebaseService = firebaseService;

  FirebaseService get _service => _firebaseService ?? FirebaseService.instance;

  /// Live auth state changes from Firebase Auth.
  Stream<User?> get authState {
    try {
      return _service.authState;
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Current Firebase user if signed in.
  User? get currentUser {
    try {
      return _service.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Sign in with email and password via Firebase Auth.
  Future<String?> signIn(String email, String password) async {
    try {
      await _service.signIn(email, password);
      return null;
    } catch (e) {
      return FirebaseService.authMessage(e);
    }
  }

  /// Sign out from Firebase Auth.
  Future<void> signOut() async {
    try {
      await _service.signOut();
    } catch (_) {}
  }
}
