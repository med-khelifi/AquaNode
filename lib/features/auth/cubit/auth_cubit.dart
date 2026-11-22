import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aqua_node/data/repositories/auth_repository.dart';
import 'package:aqua_node/features/auth/cubit/auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState());

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
    emit(const AuthState(status: AuthStatus.initial));
  }
}
