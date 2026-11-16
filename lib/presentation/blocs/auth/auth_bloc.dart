import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<AuthResetEvent>(_onAuthReset);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_authRepository.isLoggedIn) {
      emit(
        UserLoggedInState(
          uid: _authRepository.currentUserId ?? '',
          email: _authRepository.currentUserEmail ?? '',
        ),
      );
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(
        UserLoggedInState(
          uid: user?.uid ?? _authRepository.currentUserId ?? '',
          email: user?.email ?? _authRepository.currentUserEmail ?? event.email,
        ),
      );
    } catch (error) {
      emit(
        LoginFailureState(
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onAuthReset(
    AuthResetEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }
}
