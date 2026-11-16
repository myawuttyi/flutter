import 'package:equatable/equatable.dart';

abstract class RegisterEventBase extends Equatable {
  const RegisterEventBase();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the user submits Name, Email, and Password on the Register Screen.
class RegisterEvent extends RegisterEventBase {
  final String name;
  final String email;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

/// Resets registration state back to initial.
class RegisterResetEvent extends RegisterEventBase {
  const RegisterResetEvent();
}
