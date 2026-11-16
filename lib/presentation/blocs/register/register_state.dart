import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

/// Initial state before registration starts.
class RegistrationInitial extends RegisterState {
  const RegistrationInitial();
}

/// State emitted while creating the Firebase Auth account and saving to Firestore.
class RegistrationLoadingState extends RegisterState {
  const RegistrationLoadingState();
}

/// State emitted when user registration and Firestore profile creation succeed.
class RegistrationSuccessState extends RegisterState {
  final UserModel user;

  const RegistrationSuccessState({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State emitted when registration fails.
class RegistrationFailureState extends RegisterState {
  final String message;

  const RegistrationFailureState({required this.message});

  @override
  List<Object?> get props => [message];
}
