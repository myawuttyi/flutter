import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/profile/profile_bloc.dart';
import 'presentation/blocs/register/register_bloc.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase when real keys are configured in firebase_options.dart
  if (DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final authRepository = AuthRepository();
  final profileRepository = ProfileRepository();

  runApp(
    MyApp(
      authRepository: authRepository,
      profileRepository: profileRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: authRepository)
              ..add(const CheckAuthStatusEvent()),
          ),
          BlocProvider<RegisterBloc>(
            create: (_) => RegisterBloc(authRepository: authRepository),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc(profileRepository: profileRepository),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AuthGate(),
          routes: {
            AppConstants.loginRoute: (_) => const LoginScreen(),
            AppConstants.registerRoute: (_) => const RegisterScreen(),
            AppConstants.profileRoute: (_) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}

/// Checks initial authentication status on app startup and directs the user
/// to either [ProfileScreen] (if already logged in) or [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is UserLoggedInState) {
          return const ProfileScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
