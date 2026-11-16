import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch the logged-in user's profile data from Cloud Firestore.
class LoadProfileEvent extends ProfileEvent {
  final String? uid;

  const LoadProfileEvent({this.uid});

  @override
  List<Object?> get props => [uid];
}

/// Event to update the user's profile information in Cloud Firestore.
class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String? phone;
  final String? bio;
  final String? photoUrl;

  const UpdateProfileEvent({
    required this.name,
    this.phone,
    this.bio,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, phone, bio, photoUrl];
}

/// Event to sign out the current user from Firebase Authentication.
class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}
