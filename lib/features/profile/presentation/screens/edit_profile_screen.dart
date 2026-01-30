import 'package:chat_app/core/widgets/common/app_base_view.dart';
import 'package:chat_app/core/services/firestoreservice.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/core/widgets/common/app_loading_indicator.dart';
import 'package:chat_app/core/widgets/common/mysnakebar.dart';
import 'package:chat_app/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:chat_app/features/profile/presentation/widgets/edit_profile_form.dart';
import 'package:chat_app/features/profile/presentation/widgets/edit_profile_header.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  
  List<String> _expertise = [];
  bool _isLoading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName ?? "");
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _experienceController = TextEditingController(text: widget.user.experienceYears.toString());
    _expertise = List.from(widget.user.expertise);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,   // Extremely optimized for instant avatars
        maxHeight: 256,
        imageQuality: 50, // Minimum viable quality for speed
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.show(context: context, message: "Error picking image: $e", isError: true);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? photoURL = widget.user.photoURL;

      // 1. Handle Image Upload if new image selected
      if (_imageFile != null) {
        final storageService = context.read<StorageService>();
        // Upload with security checks (defined in service)
        photoURL = await storageService.uploadProfileImage(
          widget.user.id, 
          _imageFile!
        );
      }

      final updatedUser = widget.user.copyWith(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        expertise: _expertise,
        photoURL: photoURL,
      );

      await context.read<FirestoreService>().updateUser(updatedUser);

      if (mounted) {
        MySnackBar.show(context: context, message: "Profile updated!", isError: false);
        // Small delay to allow snackbar animation to start and be seen before moving back
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) context.pop();
        });
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.show(context: context, message: "Error: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return AppBaseView(
      showGlows: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const EditProfileHeader(),
              
               Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                       const SizedBox(height: 20),
                       
                       // Industry Polish: Onboarding Hint for new users
                        if (widget.user.fullName == null || widget.user.fullName!.isEmpty || (widget.user.bio ?? "").isEmpty)
                          FadeInDown(
                            duration: const Duration(milliseconds: 600),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF94).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF00FF94).withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.rocket_launch_rounded, color: Color(0xFF00FF94)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Complete your profile", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                                        Text("Adding a photo and bio helps people get to know you better.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                       // Avatar
                       EditProfileAvatar(
                         user: widget.user,
                         localImage: _imageFile,
                         onTap: _pickImage,
                       ),

                       const SizedBox(height: 16),
                       Text(
                         widget.user.fullName?.isNotEmpty == true ? widget.user.fullName! : widget.user.username, 
                         style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold)
                       ),
                       const SizedBox(height: 4),
                       Text(
                         widget.user.role.isNotEmpty ? widget.user.role : "Flutter Enthusiast", 
                         style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w600)
                       ),
                       
                       const SizedBox(height: 32),

                       // "About" Section
                       _buildAboutSection(),

                       const SizedBox(height: 20),

                       // Form Fields
                       EditProfileForm(
                         fullNameController: _fullNameController,
                         usernameController: _usernameController,
                         experienceController: _experienceController,
                         expertise: _expertise,
                         onExpertiseChanged: (newList) => setState(() => _expertise = newList),
                       ),

                       const SizedBox(height: 40),
                       
                       // Save Button
                        GestureDetector(
                          onTap: _isLoading ? null : _saveProfile,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2979FF), Color(0xFF00B0FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2979FF).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8)
                                )
                              ]
                            ),
                            child: Center(
                              child: _isLoading 
                               ? const AppLoadingIndicator(size: 24, color: Colors.white, isFullScreen: false, showTimeoutMessage: false)
                               : const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
               ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController, 
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), height: 1.5),
            decoration: InputDecoration(
              hintText: "Write a short bio about yourself...",
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero
            ),
          ),
        ],
      ),
    );
  }
}
