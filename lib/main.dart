import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_auth_profile/bloc/cart/bloc/cart_bloc_bloc.dart';
import 'package:flutter_bloc_auth_profile/bloc/login/bloc/product_bloc.dart';
//import 'package:flutter_bloc_auth_profile/bloc/cart/bloc/cart_bloc_bloc.dart';
import 'package:flutter_bloc_auth_profile/repo/productrepo.dart';
import 'package:flutter_bloc_auth_profile/ui/productlist.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'firebase_options.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProductBloc>(
            create: (_) =>
                ProductBloc(ProductRepository())..add(LoadProductEvent()),
          ),
          BlocProvider<CartBlocBloc>(
            create: (_) => CartBlocBloc(),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const ProductListPage(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is UserLoggedInState) {
          return const ProfileScreen();
        }
        return const ProductListPage();
      },
    );
  }
}