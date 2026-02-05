import 'package:nexlinks/core/utils/app_validators.dart';
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
  late TextEditingController _projectsController;
  late TextEditingController _successRateController;

  List<String> _expertise = [];
  bool _isLoading = false;
  String? _selectedAvatarUrl;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.user.fullName ?? "",
    );
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio);
    _experienceController = TextEditingController(
      text: widget.user.experienceYears == 0
          ? ""
          : widget.user.experienceYears.toString(),
    );
    _roleController = TextEditingController(text: widget.user.role);
    _projectsController = TextEditingController(
      text: widget.user.projectsCount == 0
          ? ""
          : widget.user.projectsCount.toString(),
    );
    _successRateController = TextEditingController(
      text: widget.user.successRate == 0
          ? ""
          : widget.user.successRate.toString(),
    );
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
    _projectsController.dispose();
    _successRateController.dispose();
    _scrollController.dispose();
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

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      return;
    }

    try {
      if (widget.user.id.trim().isEmpty) {
        throw "Your session profile is invalid. Please log out and back in.";
      }

      final updatedUser = widget.user.copyWith(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        role: _roleController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        expertise: _expertise,
        photoURL: _selectedAvatarUrl,
        projectsCount: int.tryParse(_projectsController.text.trim()) ?? 0,
        successRate: int.tryParse(_successRateController.text.trim()) ?? 0,
      );

      await context.read<FirestoreService>().updateUser(updatedUser);

      if (mounted) {
        MySnackBar.show(
          context: context,
          title: "Success",
          message: "Profile updated successfully!",
          isError: false,
        );
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) context.pop();
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains("ArgumentError")) {
          errorMessage =
              "App Error: User ID is missing. Try restarting the app.";
        }
        MySnackBar.show(
          context: context,
          title: "Update Failed",
          message: errorMessage,
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseView(
      showGlows: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const EditProfileHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          24,
                          0,
                          24,
                          MediaQuery.of(context).padding.bottom + 200,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            if (widget.user.fullName == null ||
                                widget.user.fullName!.isEmpty ||
                                (widget.user.bio ?? "").isEmpty)
                              FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF22D3EE,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF22D3EE,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.rocket_launch_rounded,
                                        color: Color(0xFF22D3EE),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Complete your profile",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "Adding a photo and bio helps people get to know you better.",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            TactileFeedback(
                              onTap: _selectAvatar,
                              child: EditProfileAvatar(
                                user: widget.user,
                                selectedAvatarUrl: _selectedAvatarUrl,
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              widget.user.fullName?.isNotEmpty == true
                                  ? widget.user.fullName!
                                  : widget.user.username,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.role.isNotEmpty
                                  ? widget.user.role
                                  : "Flutter Enthusiast",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 32),

                            _buildSectionHeader("Identity"),
                            _buildIdentitySection(),

                            const SizedBox(height: 32),

                            _buildSectionHeader("About"),
                            _buildAboutSection(),

                            const SizedBox(height: 32),

                            _buildSectionHeader("Professional Stats"),
                            _buildProfessionalStatsSection(),

                            const SizedBox(height: 48),
                          ],
                        ),
                      ),

                      _buildStickySaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickySaveButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: AppButton(
          text: "Save Changes",
          onPressed: _isLoading ? null : _saveProfile,
          isLoading: _isLoading,
          style: AppButtonStyle.primary,
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
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: MyTextFormField(
        controller: _bioController,
        hintText: "Write a short bio about yourself...",
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        validator: AppValidators.validateBio,
      ),
    );
  }

  Widget _buildProfessionalStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          MyTextFormField(
            controller: _projectsController,
            labelText: "Total Projects",
            hintText: "Enter number (eg: 12)",
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final number = int.tryParse(value);
              if (number == null || number < 0 || number > 999) {
                return 'Please enter a valid number (0-999)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          MyTextFormField(
            controller: _successRateController,
            labelText: "Success Rate (%)",
            hintText: "Enter percentage (eg: 95)",
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final number = int.tryParse(value);
              if (number == null || number < 0 || number > 100) {
                return 'Please enter a valid percentage (0-100)';
              }
              return null;
            },
          ),
        ],
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
