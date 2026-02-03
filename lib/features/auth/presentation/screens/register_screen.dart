import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:nexlinks/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/theme/app_theme.dart';
import 'package:nexlinks/core/widgets/common/my_textformfield.dart';
import 'package:nexlinks/core/widgets/common/mysnakebar.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_event.dart';
import 'package:nexlinks/features/auth/logic/auth_state.dart';
import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/utils/app_validators.dart';
import 'package:nexlinks/features/auth/domain/repositories/auth_repository.dart';
import 'package:nexlinks/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isCheckingUsername = false;
  bool _isPasswordValid = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_formKey1.currentState!.validate()) {
      setState(() => _isCheckingUsername = true);
      try {
        final authRepo = context.read<AuthRepository>();
        final isUnique = await authRepo.checkUsernameUnique(_usernameController.text.trim());
        if (!mounted) return;
        setState(() => _isCheckingUsername = false);

        if (!isUnique) {
          MySnackBar.show(context: context, title: "Unavailable", message: "Username is already taken.", isError: true);
          return;
        }

        if (_pageController.hasClients) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        setState(() {
          _currentStep = 1;
        });
      } catch (e) {
        if (mounted) setState(() => _isCheckingUsername = false);
        MySnackBar.show(context: context, title: "Verification Error", message: e.toString(), isError: true);
      }
    }
  }

  void _previousStep() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      _currentStep = 0;
    });
  }

  Future<void> _register() async {
    if (_formKey2.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          MySnackBar.show(context: context, title: "Register Failed", message: state.errorMessage ?? "Error", isError: true);
        } else if (state.status == AuthStatus.authenticated) {
          MySnackBar.show(context: context, title: "Registration Successful", message: "Account created!", isError: false);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading || _isCheckingUsername;
          return AppBaseView(
            isLoading: false,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(state),
                        _buildStep2(state),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const AppLoadingIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep1(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SafeArea(
        child: Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildStepIndicator(),
              const SizedBox(height: 32),
              Center(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      "User Info",
                      textStyle: Theme.of(context).textTheme.headlineLarge!,
                      speed: const Duration(milliseconds: 80),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Text("Tell us a bit about yourself",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ),
              const SizedBox(height: 40),
              _buildLabel("Full Name", delay: 100),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 100),
                child: MyTextFormField(
                  controller: _fullNameController,
                  hintText: 'Enter your full name',
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: AppValidators.validateFullName,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel("Username", delay: 200),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: MyTextFormField(
                  controller: _usernameController,
                  hintText: 'Enter your unique username',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.alternate_email),
                  validator: AppValidators.validateUsername,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel("Email", delay: 300),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 300),
                child: MyTextFormField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: AppValidators.validateEmail,
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: AppButton(
                  text: "Next",
                  onPressed: _nextStep,
                  style: AppButtonStyle.primary,
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 500),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("OR", style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SocialLoginButtons(
                onGooglePressed: () => context.read<AuthBloc>().add(AuthGoogleLoginRequested()),
                onFacebookPressed: () => context.read<AuthBloc>().add(AuthFacebookLoginRequested()),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text("Sign In", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2(AuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SafeArea(
        child: Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildStepIndicator(),
              const SizedBox(height: 32),
              Center(
                child: FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.security_rounded, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      "Security",
                      textStyle: Theme.of(context).textTheme.headlineLarge!,
                      speed: const Duration(milliseconds: 80),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Text("Set up your password",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              ),
              const SizedBox(height: 40),
              _buildLabel("Password", delay: 100),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 100),
                child: MyTextFormField(
                  controller: _passwordController,
                  hintText: 'Enter your password',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: true,
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              if (!_isPasswordValid)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: FlutterPwValidator(
                        controller: _passwordController,
                        minLength: 6,
                        uppercaseCharCount: 1,
                        specialCharCount: 1,
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                        onSuccess: () {
                          setState(() {
                            _isPasswordValid = true;
                          });
                          Future.delayed(const Duration(milliseconds: 300), () {
                            setState(() {
                              _showConfirmPassword = true;
                            });
                          });
                        },
                        onFail: () {
                          setState(() {
                            _isPasswordValid = false;
                            _showConfirmPassword = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              AnimatedCrossFade(
                firstChild: const SizedBox(height: 0, width: double.infinity),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildLabel("Confirm Password"),
                    MyTextFormField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm your password',
                      keyboardType: TextInputType.text,
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: true,
                      onChanged: (val) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) return "Please confirm your password";
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
              if (_showConfirmPassword)
                AppButton(
                  text: "Create Account",
                  onPressed: _register,
                  isLoading: state.status == AuthStatus.loading,
                  style: AppButtonStyle.primary,
                ),
                  ],
                ),
                crossFadeState: _showConfirmPassword ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 500),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: Center(
                  child: TextButton(
                    onPressed: _previousStep,
                    child: Text("Back to User Info", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final isActive = _currentStep == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: isActive ? 60 : 40,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text, {int delay = 0}) {
    if (delay == 0) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      );
    }
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 4.0),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
