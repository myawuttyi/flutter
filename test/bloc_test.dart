import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_auth_profile/data/models/user_model.dart';
import 'package:flutter_bloc_auth_profile/data/repositories/auth_repository.dart';
import 'package:flutter_bloc_auth_profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/auth/auth_event.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/profile/profile_event.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/profile/profile_state.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/register/register_bloc.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/register/register_event.dart';
import 'package:flutter_bloc_auth_profile/presentation/blocs/register/register_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockProfileRepository mockProfileRepository;
  late MockUser mockUser;

  final testUserModel = UserModel(
    uid: 'uid_12345',
    name: 'Aung Min',
    email: 'aungmin@yahoo.com',
    phone: '+959123456789',
    bio: 'Senior Flutter Developer',
    photoUrl: '',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockProfileRepository = MockProfileRepository();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('uid_12345');
    when(() => mockUser.email).thenReturn('aungmin@yahoo.com');
  });

  group('AuthBloc Tests', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, UserLoggedInState] when LoginEvent succeeds',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'aungmin@yahoo.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => mockUser);
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginEvent(
          email: 'aungmin@yahoo.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const AuthLoadingState(),
        const UserLoggedInState(
          uid: 'uid_12345',
          email: 'aungmin@yahoo.com',
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoadingState, LoginFailureState] when LoginEvent fails',
      build: () {
        when(
          () => mockAuthRepository.login(
            email: 'aungmin@yahoo.com',
            password: 'wrongpassword',
          ),
        ).thenThrow(Exception('Invalid email or password. Please try again.'));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const LoginEvent(
          email: 'aungmin@yahoo.com',
          password: 'wrongpassword',
        ),
      ),
      expect: () => [
        const AuthLoadingState(),
        const LoginFailureState(
          message: 'Invalid email or password. Please try again.',
        ),
      ],
    );
  });

  group('RegisterBloc Tests', () {
    blocTest<RegisterBloc, RegisterState>(
      'emits [RegistrationLoadingState, RegistrationSuccessState] when RegisterEvent succeeds',
      build: () {
        when(
          () => mockAuthRepository.register(
            name: 'Aung Min',
            email: 'aungmin@yahoo.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testUserModel);
        return RegisterBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const RegisterEvent(
          name: 'Aung Min',
          email: 'aungmin@yahoo.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const RegistrationLoadingState(),
        RegistrationSuccessState(user: testUserModel),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [RegistrationLoadingState, RegistrationFailureState] when RegisterEvent fails',
      build: () {
        when(
          () => mockAuthRepository.register(
            name: 'Aung Min',
            email: 'aungmin@yahoo.com',
            password: 'password123',
          ),
        ).thenThrow(Exception('This email is already registered.'));
        return RegisterBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(
        const RegisterEvent(
          name: 'Aung Min',
          email: 'aungmin@yahoo.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        const RegistrationLoadingState(),
        const RegistrationFailureState(
          message: 'This email is already registered.',
        ),
      ],
    );
  });

  group('ProfileBloc Tests', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoadingState, ProfileLoadedState] when LoadProfileEvent succeeds',
      build: () {
        when(() => mockProfileRepository.getUserProfile(uid: any(named: 'uid')))
            .thenAnswer((_) async => testUserModel);
        return ProfileBloc(profileRepository: mockProfileRepository);
      },
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        const ProfileLoadingState(),
        ProfileLoadedState(userData: testUserModel),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoadingState, ProfileLoggedOutState] when LogoutEvent succeeds',
      build: () {
        when(() => mockProfileRepository.logout()).thenAnswer((_) async {});
        return ProfileBloc(profileRepository: mockProfileRepository);
      },
      act: (bloc) => bloc.add(const LogoutEvent()),
      expect: () => [
        const ProfileLoadingState(),
        const ProfileLoggedOutState(),
      ],
    );
  });
}
