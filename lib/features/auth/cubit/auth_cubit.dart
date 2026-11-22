import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/data/repositories/auth_repository.dart';
import 'package:aqua_node/features/auth/cubit/auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(_initialState(authRepository)) {
    _listenToAuthState();
  }

  static AuthState _initialState(AuthRepository repo) {
    final user = repo.currentUser;
    if (user != null) {
      return AuthState(
        status: AuthStatus.authenticated,
        email: user.email,
      );
    }
    return const AuthState(status: AuthStatus.initial);
  }

  void _listenToAuthState() {
    _authSubscription = _authRepository.authState.listen((user) {
      if (user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          email: user.email,
        ));
      } else if (state.status == AuthStatus.authenticated) {
        emit(const AuthState(status: AuthStatus.initial));
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final error = await _authRepository.signIn(email, password);
    if (error != null) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: error));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, email: email));
    }
  }

  void signOut() {
    _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.initial));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
