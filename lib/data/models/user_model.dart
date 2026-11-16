import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.photoUrl = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserModel] from a Cloud Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return UserModel.fromMap(data, fallbackUid: doc.id);
  }

  /// Creates a [UserModel] from a key-value map.
  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    String fallbackUid = '',
  }) {
    return UserModel(
      uid: (map[AppConstants.fieldUid] as String?) ?? fallbackUid,
      name: (map[AppConstants.fieldName] as String?) ?? 'User',
      email: (map[AppConstants.fieldEmail] as String?) ?? '',
      phone: (map[AppConstants.fieldPhone] as String?) ?? '',
      bio: (map[AppConstants.fieldBio] as String?) ?? '',
      photoUrl: (map[AppConstants.fieldPhotoUrl] as String?) ?? '',
      createdAt: _parseDateTime(map[AppConstants.fieldCreatedAt]),
      updatedAt: _parseDateTime(map[AppConstants.fieldUpdatedAt]),
    );
  }

  /// Converts [UserModel] to a Map for saving in Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      AppConstants.fieldUid: uid,
      AppConstants.fieldName: name,
      AppConstants.fieldEmail: email,
      AppConstants.fieldPhone: phone,
      AppConstants.fieldBio: bio,
      AppConstants.fieldPhotoUrl: photoUrl,
      AppConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      AppConstants.fieldUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  /// Creates a copy of [UserModel] with updated fields.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Helper to get user initials for Avatar display.
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        phone,
        bio,
        photoUrl,
        createdAt,
        updatedAt,
      ];
}
