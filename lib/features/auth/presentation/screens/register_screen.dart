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

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCheckingUsername = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }



  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
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

        context.read<AuthBloc>().add(AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
        ));
      } catch (e) {
        if(mounted) setState(() => _isCheckingUsername = false);
        MySnackBar.show(context: context, title: "Verification Error", message: e.toString(), isError: true);
      }
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
          return AppBaseView(
            isLoading: state.status == AuthStatus.loading || _isCheckingUsername,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                "Create Account",
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
                          child: Text("Fill in your details to get started", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                        ),
                        const SizedBox(height: 40),
                        _buildLabel("Username"),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 100),
                          child: MyTextFormField(
                            controller: _usernameController,
                            hintText: 'Enter your unique username',
                            keyboardType: TextInputType.text,
                            prefixIcon: const Icon(Icons.person_outline),
                             validator: AppValidators.validateUsername,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Email"),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: MyTextFormField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                             validator: AppValidators.validateEmail,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Password"),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 300),
                          child: MyTextFormField(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            keyboardType: TextInputType.text,
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: true,
                             validator: AppValidators.validatePassword,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Confirm Password"),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 400),
                          child: MyTextFormField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm your password',
                            keyboardType: TextInputType.text,
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return "Please enter your confirm password";
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 500),
                          child: AppButton(
                            text: "Create Account",
                            onPressed: _register,
                            isLoading: state.status == AuthStatus.loading || _isCheckingUsername,
                            style: AppButtonStyle.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 600),
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
                        const SizedBox(height: 32),
                        SocialLoginButtons(
                          onGooglePressed: () => context.read<AuthBloc>().add(AuthGoogleLoginRequested()),
                          onFacebookPressed: () => context.read<AuthBloc>().add(AuthFacebookLoginRequested()),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 700),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?", style: Theme.of(context).textTheme.bodyMedium),
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
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
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
