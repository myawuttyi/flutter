import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/models/user_model.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch user profile data from Cloud Firestore when ProfileScreen opens
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  /// Resolves an [ImageProvider] from either a Base64 data URI or an HTTP/HTTPS URL.
  ImageProvider? _resolveAvatarImage(String photoUrl) {
    final trimmed = photoUrl.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final base64String = trimmed.substring(commaIndex + 1);
          final Uint8List bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        }
      } catch (_) {
        return null;
      }
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    return null;
  }

  /// Picks an image from [source] (Gallery or Camera) and converts it to a
  /// compact Base64 Data URI so it works both offline and in Cloud Firestore.
  Future<String?> _pickImageAsDataUrl(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 75,
      );
      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64Image';
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Could not pick image: $error'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
      }
      return null;
    }
  }

  /// Shows a bottom sheet when tapping the Avatar to upload/change the profile photo.
  void _showPhotoOptionsSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Update Profile Photo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: const Text(
                    'Choose from Device / Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Select a photo from your files'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final dataUrl =
                        await _pickImageAsDataUrl(ImageSource.gallery);
                    if (dataUrl != null && mounted) {
                      context.read<ProfileBloc>().add(
                            UpdateProfileEvent(
                              name: user.name,
                              phone: user.phone,
                              bio: user.bio,
                              photoUrl: dataUrl,
                            ),
                          );
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Use your camera to capture a photo'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final dataUrl =
                        await _pickImageAsDataUrl(ImageSource.camera);
                    if (dataUrl != null && mounted) {
                      context.read<ProfileBloc>().add(
                            UpdateProfileEvent(
                              name: user.name,
                              phone: user.phone,
                              bio: user.bio,
                              photoUrl: dataUrl,
                            ),
                          );
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: const Text(
                    'Enter Image URL',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Paste a direct https:// image link'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showImageUrlDialog(context, user);
                  },
                ),
                if (user.photoUrl.isNotEmpty)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.errorRed,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorRed,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.read<ProfileBloc>().add(
                            UpdateProfileEvent(
                              name: user.name,
                              phone: user.phone,
                              bio: user.bio,
                              photoUrl: '',
                            ),
                          );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Dialog to paste a direct image URL.
  void _showImageUrlDialog(BuildContext context, UserModel user) {
    final urlController = TextEditingController(
      text: user.photoUrl.startsWith('http') ? user.photoUrl : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Image URL'),
        content: CustomTextField(
          controller: urlController,
          label: 'Photo URL',
          hintText: 'https://example.com/avatar.jpg',
          prefixIcon: Icons.link_rounded,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 42),
            ),
            onPressed: () {
              final url = urlController.text.trim();
              Navigator.of(dialogContext).pop();
              context.read<ProfileBloc>().add(
                    UpdateProfileEvent(
                      name: user.name,
                      phone: user.phone,
                      bio: user.bio,
                      photoUrl: url,
                    ),
                  );
            },
            child: const Text('Save Photo'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final bioController = TextEditingController(text: user.bio);
    String selectedPhotoUrl = user.photoUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final avatarProvider = _resolveAvatarImage(selectedPhotoUrl);

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Photo Picker Preview inside Edit Profile
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final dataUrl = await _pickImageAsDataUrl(
                                  ImageSource.gallery,
                                );
                                if (dataUrl != null) {
                                  setModalState(() {
                                    selectedPhotoUrl = dataUrl;
                                  });
                                }
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 42,
                                    backgroundColor:
                                        AppTheme.primaryBlue.withOpacity(0.12),
                                    backgroundImage: avatarProvider,
                                    child: avatarProvider == null
                                        ? Text(
                                            user.initials,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          )
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final dataUrl = await _pickImageAsDataUrl(
                                  ImageSource.gallery,
                                );
                                if (dataUrl != null) {
                                  setModalState(() {
                                    selectedPhotoUrl = dataUrl;
                                  });
                                }
                              },
                              icon: const Icon(
                                Icons.upload_rounded,
                                size: 18,
                              ),
                              label: const Text('Upload Photo'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: nameController,
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        hintText: '+95 9 123 456 789',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: bioController,
                        label: 'Bio / Role',
                        hintText: 'Tell us a little about yourself',
                        prefixIcon: Icons.info_outline,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Save Changes',
                        icon: Icons.check_circle_outline,
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.of(sheetContext).pop();
                            context.read<ProfileBloc>().add(
                                  UpdateProfileEvent(
                                    name: nameController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    bio: bioController.text.trim(),
                                    photoUrl: selectedPhotoUrl,
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              minimumSize: const Size(96, 42),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ProfileBloc>().add(const LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh Profile',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<ProfileBloc>().add(const LoadProfileEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoggedOutState) {
            context.read<AuthBloc>().add(const AuthResetEvent());
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppConstants.loginRoute,
              (route) => false,
            );
          } else if (state is ProfileLoadedState &&
              state.feedbackMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.feedbackMessage!),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
          } else if (state is ProfileErrorState) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoadingState || state is ProfileInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading user profile...',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxCardWidth,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.errorRed,
                            size: 52,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to Load Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Retry',
                            icon: Icons.refresh_rounded,
                            onPressed: () {
                              context
                                  .read<ProfileBloc>()
                                  .add(const LoadProfileEvent());
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Logout',
                            isOutlined: true,
                            backgroundColor: AppTheme.errorRed,
                            onPressed: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          if (state is ProfileLoadedState) {
            final user = state.userData;
            final avatarProvider = _resolveAvatarImage(user.photoUrl);

            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.maxCardWidth,
                    ),
                    child: Column(
                      children: [
                        // User Profile Header & Avatar Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Clickable User Profile Avatar with Camera Upload Badge
                                GestureDetector(
                                  onTap: () =>
                                      _showPhotoOptionsSheet(context, user),
                                  child: Tooltip(
                                    message: 'Tap to change profile photo',
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 50,
                                          backgroundColor: AppTheme.primaryBlue
                                              .withOpacity(0.12),
                                          backgroundImage: avatarProvider,
                                          child: avatarProvider == null
                                              ? Text(
                                                  user.initials,
                                                  style: const TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppTheme.primaryBlue,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // User Name
                                Text(
                                  user.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Email Address
                                Text(
                                  user.email,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (user.bio.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.primaryBlue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      user.bio,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                const Divider(height: 1),
                                const SizedBox(height: 20),
                                // User Information Section (Matches Reference Image)
                                _ProfileInfoTile(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Name',
                                  value: user.name,
                                ),
                                const SizedBox(height: 14),
                                _ProfileInfoTile(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: user.email,
                                ),
                                const SizedBox(height: 14),
                                _ProfileInfoTile(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: user.phone.isNotEmpty
                                      ? user.phone
                                      : 'Not provided',
                                ),
                                const SizedBox(height: 14),
                                _ProfileInfoTile(
                                  icon: Icons.badge_outlined,
                                  label: 'User ID',
                                  value: user.uid,
                                ),
                                const SizedBox(height: 24),
                                // Edit Profile Button
                                CustomButton(
                                  text: 'Edit Profile',
                                  icon: Icons.edit_outlined,
                                  isOutlined: true,
                                  onPressed: () =>
                                      _showEditProfileDialog(context, user),
                                ),
                                const SizedBox(height: 12),
                                // Logout Button
                                CustomButton(
                                  text: 'Logout',
                                  icon: Icons.logout_rounded,
                                  backgroundColor: AppTheme.primaryBlue,
                                  onPressed: () => _confirmLogout(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
