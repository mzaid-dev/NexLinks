import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';

import 'package:nexlinks/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/theme/app_theme.dart';
import 'package:nexlinks/core/widgets/common/my_textformfield.dart';
import 'package:nexlinks/core/widgets/common/mysnakebar.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_event.dart';
import 'package:nexlinks/features/auth/logic/auth_state.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/utils/app_validators.dart';
import 'package:nexlinks/features/auth/presentation/widgets/social_login_buttons.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
             MySnackBar.show(
              context: context,
              title: "Login Failed",
              message: state.errorMessage ?? "An error occurred",
              isError: true,
            );
        } else if (state.status == AuthStatus.authenticated) {
            MySnackBar.show(
              context: context,
              title: "Welcome Back",
              message: "You have successfully logged in.",
              isError: false,
            );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;
          return AppBaseView(
            isLoading: false,
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SafeArea(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 40),
                              Center(
                                child: FadeInUp(
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
                                      "Welcome Back !",
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
                                child: Text(
                                  "Sign In to continue chatting with friends & family",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildLabel("Email"),
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 100),
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
                                delay: const Duration(milliseconds: 200),
                                child: MyTextFormField(
                                  controller: _passwordController,
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  validator: AppValidators.validatePassword,
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 400),
                                child: AppButton(
                                  text: "Sign In",
                                  onPressed: _login,
                                  isLoading: isLoading,
                                  style: AppButtonStyle.primary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 500),
                                child: Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Text("OR", style: TextStyle(fontSize: 12)),
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
                                delay: const Duration(milliseconds: 600),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't have an account?", style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => context.go(AppRoutes.register),
                                      child: const Text("Sign Up",
                                          style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: AppLoadingIndicator(),
                    ),
                  ),
              ],
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
