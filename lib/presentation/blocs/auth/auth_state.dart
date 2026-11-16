import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication action is taken.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State emitted while login or auth check is in progress.
class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

/// State emitted when a user is successfully authenticated.
class UserLoggedInState extends AuthState {
  final String uid;
  final String email;

  const UserLoggedInState({
    required this.uid,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, email];
}

/// State emitted when login fails with an error message.
class LoginFailureState extends AuthState {
  final String message;

  const LoginFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
