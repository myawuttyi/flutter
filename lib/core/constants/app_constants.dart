class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Flutter BLoC Auth';
  static const String appTagline = 'Authentication & User Profile System';

  // Firestore Collections & Fields
  static const String usersCollection = 'users';
  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldBio = 'bio';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // Route Names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';

  // Layout Constraints
  static const double maxCardWidth = 440.0;
  static const double defaultPadding = 24.0;
  static const double borderRadius = 14.0;
}
