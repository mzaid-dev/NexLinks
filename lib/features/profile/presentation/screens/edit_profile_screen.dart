import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/core/widgets/common/mysnakebar.dart';
import 'package:nexlinks/features/profile/presentation/widgets/edit_profile_avatar.dart';
import 'package:nexlinks/features/profile/presentation/widgets/edit_profile_form.dart';
import 'package:nexlinks/features/profile/presentation/widgets/edit_profile_header.dart';
import 'package:nexlinks/features/profile/presentation/widgets/avatar_selector_sheet.dart';
import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
import 'package:nexlinks/core/widgets/common/my_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:go_router/go_router.dart';

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
  late TextEditingController _roleController;
  
  List<String> _expertise = [];
  bool _isLoading = false;
  String? _selectedAvatarUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName ?? "");
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _experienceController = TextEditingController(text: widget.user.experienceYears.toString());
    _roleController = TextEditingController(text: widget.user.role);
    _expertise = List.from(widget.user.expertise);
    _selectedAvatarUrl = widget.user.photoURL;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _selectAvatar() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AvatarSelectorSheet(),
    );

    if (result != null) {
      setState(() {
        _selectedAvatarUrl = result;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final updatedUser = widget.user.copyWith(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        role: _roleController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        expertise: _expertise,
        photoURL: _selectedAvatarUrl,
      );

      await context.read<FirestoreService>().updateUser(updatedUser);

      if (mounted) {
        MySnackBar.show(context: context, message: "Profile updated!", isError: false);
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
                                color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.rocket_launch_rounded, color: Color(0xFF22D3EE)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Complete your profile", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                                        Text("Adding a photo and bio helps people get to know you better.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                       // Avatar
                       TactileFeedback(
                         onTap: _selectAvatar,
                         child: EditProfileAvatar(
                           user: widget.user,
                           selectedAvatarUrl: _selectedAvatarUrl,
                         ),
                       ),

                       const SizedBox(height: 16),
                       Text(
                         widget.user.fullName?.isNotEmpty == true ? widget.user.fullName! : widget.user.username, 
                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                           fontWeight: FontWeight.w900,
                           letterSpacing: -1.0,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         widget.user.role.isNotEmpty ? widget.user.role : "Flutter Enthusiast", 
                         style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.w700)
                       ),
                       
                       const SizedBox(height: 32),

                       // 1. Identity Section
                       _buildSectionHeader("Identity"),
                       _buildIdentitySection(),

                       const SizedBox(height: 32),

                       // 2. "About" Section
                       _buildSectionHeader("About"),
                       _buildAboutSection(),


                       const SizedBox(height: 40),
                       
                       // Save Button
                       AppButton(
                         text: "Save Changes",
                         onPressed: _isLoading ? null : _saveProfile,
                         isLoading: _isLoading,
                         style: AppButtonStyle.primary,
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


  Widget _buildIdentitySection() {
    return EditProfileForm(
      fullNameController: _fullNameController,
      usernameController: _usernameController,
      roleController: _roleController,
      experienceController: _experienceController,
      expertise: _expertise,
      onExpertiseChanged: (newList) => setState(() => _expertise = newList),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1))),
      child: MyTextFormField(
        controller: _bioController,
        hintText: "Write a short bio about yourself...",
        keyboardType: TextInputType.multiline,
        maxLines: 4,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
