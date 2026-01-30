import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:email_validator/email_validator.dart';
import 'package:chat_app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/common/my_textformfield.dart';
import 'package:chat_app/core/widgets/common/mysnakebar.dart';
import 'package:chat_app/features/auth/logic/auth_bloc.dart';
import 'package:chat_app/features/auth/logic/auth_event.dart';
import 'package:chat_app/features/auth/logic/auth_state.dart';
import 'package:chat_app/core/widgets/common/app_base_view.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obsecurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obsecurePassword = !_obsecurePassword);
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
          return AppBaseView(
            isLoading: state.status == AuthStatus.loading,
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
                          child: Text("Welcome Back !", style: Theme.of(context).textTheme.headlineLarge),
                        ),
                        const SizedBox(height: 8),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "Sign In to continue chatting with friends & family",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 100),
                          child: MyTextFormField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Please enter your email';
                              if (!EmailValidator.validate(value!)) return 'Please enter a valid email';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: MyTextFormField(
                            controller: _passwordController,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            keyboardType: TextInputType.text,
                            obscureText: _obsecurePassword,
                            suffixIcon: Icon(_obsecurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onSuffixIconPressed: _togglePasswordVisibility,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Please enter your password';
                              if (value!.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                           duration: const Duration(milliseconds: 800),
                           delay: const Duration(milliseconds: 300),
                           child: Center(
                            child: TextButton(
                              onPressed: () => context.push(AppRoutes.forgotPassword),
                              child: const Text("Forgot Password?", style: TextStyle(color: AppTheme.primaryColor)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.status == AuthStatus.loading ? null : _login,
                              child: const Text("Sign In"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
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
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 600),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?", style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.register),
                                child: Text("Sign Up", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
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
          );
        },
      ),
    );
  }
}
