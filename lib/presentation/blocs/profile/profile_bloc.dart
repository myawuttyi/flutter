import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    try {
      final userData = await _profileRepository.getUserProfile(uid: event.uid);
      emit(ProfileLoadedState(userData: userData));
    } catch (error) {
      emit(
        ProfileErrorState(
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    try {
      final updatedUserData = await _profileRepository.updateUserProfile(
        name: event.name,
        phone: event.phone,
        bio: event.bio,
        photoUrl: event.photoUrl,
      );
      emit(
        ProfileLoadedState(
          userData: updatedUserData,
          feedbackMessage: 'Profile updated successfully!',
        ),
      );
    } catch (error) {
      emit(
        ProfileErrorState(
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    try {
      await _profileRepository.logout();
      emit(const ProfileLoggedOutState());
    } catch (error) {
      emit(
        ProfileErrorState(
          message: error.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
