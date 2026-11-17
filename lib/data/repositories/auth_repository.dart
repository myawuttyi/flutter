import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../firebase_options.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;
  final bool _useFirebase;

  // In-memory store used only when Firebase keys are not yet configured
  static UserModel? _demoCurrentUser;
  static final Map<String, String> _demoPasswords = {
    'aungmin@yahoo.com': '123456',
  };
  static final Map<String, UserModel> _demoUsers = {
    'aungmin@yahoo.com': UserModel(
      uid: 'demo_uid_001',
      name: 'Aung Min',
      email: 'aungmin@yahoo.com',
      phone: '+95 9 123 456 789',
      bio: 'Senior Flutter Developer',
      photoUrl: '',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  };
 
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    bool? useFirebase,
  })  : _useFirebase = useFirebase ??
            (firebaseAuth != null ||
                firestore != null ||
                DefaultFirebaseOptions.isConfigured),
        _firebaseAuth = (useFirebase ??
                (firebaseAuth != null || DefaultFirebaseOptions.isConfigured))
            ? (firebaseAuth ?? FirebaseAuth.instance)
            : null,
        _firestore = (useFirebase ??
                (firestore != null || DefaultFirebaseOptions.isConfigured))
            ? (firestore ?? FirebaseFirestore.instance)
            : null;

  /// Returns the currently signed-in Firebase [User], or null if signed out.
  User? get currentUser => _useFirebase ? _firebaseAuth?.currentUser : null;

  /// Returns the active user ID (from Firebase Auth or Demo Mode).
  String? get currentUserId =>
      _useFirebase ? _firebaseAuth?.currentUser?.uid : _demoCurrentUser?.uid;

  /// Returns the active user email (from Firebase Auth or Demo Mode).
  String? get currentUserEmail => _useFirebase
      ? _firebaseAuth?.currentUser?.email
      : _demoCurrentUser?.email;

  /// Checks whether a user is currently authenticated.
  bool get isLoggedIn =>
      _useFirebase ? _firebaseAuth?.currentUser != null : _demoCurrentUser != null;

  /// Accessor for Demo Mode profile repository sync.
  static UserModel? get demoCurrentUser => _demoCurrentUser;
  static set demoCurrentUser(UserModel? user) {
    _demoCurrentUser = user;
    if (user != null) {
      _demoUsers[user.email.toLowerCase()] = user;
    }
  }

  /// Signs in a user with [email] and [password] using Firebase Authentication.
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_useFirebase) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final savedPassword = _demoPasswords[normalizedEmail];
      if (savedPassword == null || savedPassword != password) {
        throw Exception('Invalid email or password. (Demo: aungmin@yahoo.com / 123456)');
      }
      _demoCurrentUser = _demoUsers[normalizedEmail];
      return null;
    }

    try {
      final UserCredential credential =
          await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Login failed: User session could not be created.');
      }
      return user;
    } catch (error) {
      throw Exception(Validators.mapFirebaseAuthError(error));
    }
  }

  /// Registers a new user account in Firebase Authentication and saves
  /// their [UserModel] profile document inside Cloud Firestore.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (!_useFirebase) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (_demoUsers.containsKey(normalizedEmail)) {
        throw Exception('This email is already registered. Please login instead.');
      }
      final now = DateTime.now();
      final demoUser = UserModel(
        uid: 'demo_${now.millisecondsSinceEpoch}',
        name: name.trim(),
        email: email.trim(),
        phone: '',
        bio: 'Flutter Developer & BLoC Enthusiast',
        photoUrl: '',
        createdAt: now,
        updatedAt: now,
      );
      _demoPasswords[normalizedEmail] = password;
      _demoUsers[normalizedEmail] = demoUser;
      _demoCurrentUser = demoUser;
      return demoUser;
    }

    try {
      final UserCredential credential =
          await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Registration failed: Unable to create user account.');
      }

      // Update Firebase Auth display name
      await user.updateDisplayName(name.trim());

      final now = DateTime.now();
      final newUser = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: '',
        bio: 'Flutter Developer & BLoC Enthusiast',
        photoUrl: user.photoURL ?? '',
        createdAt: now,
        updatedAt: now,
      );

      // Save user profile document to Cloud Firestore `users/{uid}`
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(newUser.toMap());

      return newUser;
    } catch (error) {
      throw Exception(Validators.mapFirebaseAuthError(error));
    }
  }

  /// Signs out the current user from Firebase Authentication.
  Future<void> logout() async {
    if (!_useFirebase) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _demoCurrentUser = null;
      return;
    }

    try {
      await _firebaseAuth!.signOut();
    } catch (error) {
      throw Exception('Failed to logout: ${error.toString()}');
    }
  }
}
