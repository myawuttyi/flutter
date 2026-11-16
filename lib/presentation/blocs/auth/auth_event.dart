import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the app starts to check if a user is already logged in.
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

/// Event triggered when the user submits email and password on the Login Screen.
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered to reset AuthBloc back to initial state (e.g., after logout).
class AuthResetEvent extends AuthEvent {
  const AuthResetEvent();
}
