import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state before profile data is requested.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// State emitted while fetching or updating profile data.
class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

/// State emitted when user profile data is successfully loaded or updated.
class ProfileLoadedState extends ProfileState {
  final UserModel userData;
  final String? feedbackMessage;

  const ProfileLoadedState({
    required this.userData,
    this.feedbackMessage,
  });

  @override
  List<Object?> get props => [userData, feedbackMessage];
}

/// State emitted when an error occurs while fetching, updating, or logging out.
class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State emitted when the user successfully logs out.
class ProfileLoggedOutState extends ProfileState {
  const ProfileLoggedOutState();
}
