import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../firebase_options.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class ProfileRepository {
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;
  final bool _useFirebase;

  ProfileRepository({
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

  /// Returns the currently logged-in user's UID from Firebase Auth.
  String? get currentUserId => _useFirebase
      ? _firebaseAuth?.currentUser?.uid
      : AuthRepository.demoCurrentUser?.uid;

  /// Fetches the user profile data from Cloud Firestore (`users/{uid}`).
  Future<UserModel> getUserProfile({String? uid}) async {
    if (!_useFirebase) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final demoUser = AuthRepository.demoCurrentUser;
      if (demoUser == null) {
        throw Exception('No authenticated user found. Please login again.');
      }
      return demoUser;
    }

    try {
      final currentUser = _firebaseAuth!.currentUser;
      final targetUid = uid ?? currentUser?.uid;

      if (targetUid == null || targetUid.isEmpty) {
        throw Exception('No authenticated user found. Please login again.');
      }

      final docRef =
          _firestore!.collection(AppConstants.usersCollection).doc(targetUid);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromFirestore(docSnapshot);
      }

      final now = DateTime.now();
      final fallbackUser = UserModel(
        uid: targetUid,
        name: currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : 'User',
        email: currentUser?.email ?? '',
        phone: currentUser?.phoneNumber ?? '',
        bio: '',
        photoUrl: currentUser?.photoURL ?? '',
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(fallbackUser.toMap());
      return fallbackUser;
    } catch (error) {
      throw Exception(
        error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Updates the user profile data in Cloud Firestore and syncs displayName
  /// with Firebase Authentication.
  Future<UserModel> updateUserProfile({
    required String name,
    String? phone,
    String? bio,
    String? photoUrl,
  }) async {
    if (!_useFirebase) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final existing = AuthRepository.demoCurrentUser;
      if (existing == null) {
        throw Exception('No authenticated user found. Please login again.');
      }
      final updated = existing.copyWith(
        name: name.trim(),
        phone: phone?.trim() ?? existing.phone,
        bio: bio?.trim() ?? existing.bio,
        photoUrl: photoUrl?.trim() ?? existing.photoUrl,
        updatedAt: DateTime.now(),
      );
      AuthRepository.demoCurrentUser = updated;
      return updated;
    }

    try {
      final currentUser = _firebaseAuth!.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found. Please login again.');
      }

      final docRef = _firestore!
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid);

      final existingProfile = await getUserProfile(uid: currentUser.uid);
      final now = DateTime.now();

      final updatedProfile = existingProfile.copyWith(
        name: name.trim(),
        phone: phone?.trim() ?? existingProfile.phone,
        bio: bio?.trim() ?? existingProfile.bio,
        photoUrl: photoUrl?.trim() ?? existingProfile.photoUrl,
        updatedAt: now,
      );

      await docRef.set(updatedProfile.toMap(), SetOptions(merge: true));

      if (currentUser.displayName != name.trim()) {
        await currentUser.updateDisplayName(name.trim());
      }

      return updatedProfile;
    } catch (error) {
      throw Exception(
        'Failed to update profile: ${error.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  /// Signs out the current user from Firebase Authentication.
  Future<void> logout() async {
    if (!_useFirebase) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      AuthRepository.demoCurrentUser = null;
      return;
    }

    try {
      await _firebaseAuth!.signOut();
    } catch (error) {
      throw Exception('Failed to logout: ${error.toString()}');
    }
  }
}
