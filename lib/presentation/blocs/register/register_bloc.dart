import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEventBase, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const RegistrationInitial()) {
    on<RegisterEvent>(_onRegister);
    on<RegisterResetEvent>(_onReset);
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegistrationLoadingState());
    try {
      final userModel = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(RegistrationSuccessState(user: userModel));
    } catch (error) {
      emit(
        RegistrationFailureState(
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onReset(
    RegisterResetEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(const RegistrationInitial());
  }
}
