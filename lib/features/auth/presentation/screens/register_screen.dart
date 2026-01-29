import 'package:go_router/go_router.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/auth/presentation/widgets/my_textformfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/router/route_names.dart';
import 'package:animate_do/animate_do.dart';

import '../widgets/mysnakebar.dart';
import 'package:chat_app/features/auth/logic/auth_bloc.dart';
import 'package:chat_app/features/auth/logic/auth_event.dart';
import 'package:chat_app/features/auth/logic/auth_state.dart';

import 'package:chat_app/core/services/auth_service.dart'; // Add import

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

  bool _obsecurePassword = true;
  bool _obsecureConfirmPassword = true;
  bool _isCheckingUsername = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obsecurePassword = !_obsecurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obsecureConfirmPassword = !_obsecureConfirmPassword);
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCheckingUsername = true);
      try {
        final authService = context.read<AuthService>();
        final isUnique = await authService.checkUsernameUnique(_usernameController.text.trim());
        
        if (!mounted) return;
        setState(() => _isCheckingUsername = false);

        if (!isUnique) {
           MySnackBar.show(
            context: context,
            title: "Unavailable",
            message: "Username is already taken. Please choose another.",
            isError: true,
          );
          return;
        }

        context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          ),
        );
      } catch (e) {
        debugPrint("Registration Error: $e"); // Log error for debugging
        if(mounted) setState(() => _isCheckingUsername = false);
         // Friendly error message for checking username
         MySnackBar.show(
            context: context,
            title: "Verification Error",
            message: "Error: ${e.toString()}", // Show actual error for debugging
            isError: true,
          );
      }
    }
  }
  // title: "Connection Error",
  //           message: "Unable to verify username. Please check your internet connection.

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
             MySnackBar.show(
              context: context,
              title: "Register Failed",
              message: state.errorMessage ?? "An error occurred",
              isError: true,
            );
        } else if (state.status == AuthStatus.authenticated) {
            MySnackBar.show(
              context: context,
              title: "Registration Successful",
              message: "Your account has been created!",
              isError: false,
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        "Fill in your details to get started",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInUp(
                       duration: const Duration(milliseconds: 800),
                       delay: const Duration(milliseconds: 100),
                      child: MyTextFormField(
                        controller: _usernameController,
                        labelText: 'Username',
                        hintText: 'Enter your unique username',
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) =>
                        (value?.isEmpty ?? true) ? 'Please enter your username' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
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
                       delay: const Duration(milliseconds: 300),
                      child: MyTextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: _obsecurePassword,
                        suffixIcon: Icon(
                          _obsecurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
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
                       delay: const Duration(milliseconds: 400),
                      child: MyTextFormField(
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.text,
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        obscureText: _obsecureConfirmPassword,
                        suffixIcon: Icon(
                          _obsecureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onSuffixIconPressed: _toggleConfirmPasswordVisibility,
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
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (state.status == AuthStatus.loading || _isCheckingUsername) ? null : _register,
                              child: (state.status == AuthStatus.loading || _isCheckingUsername)
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text("Create Account"),
                            ),
                          );
                        }
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                       duration: const Duration(milliseconds: 800),
                       delay: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          const Expanded(child: Divider(color: AppTheme.borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("OR", style: Theme.of(context).textTheme.bodySmall),
                          ),
                          const Expanded(child: Divider(color: AppTheme.borderColor)),
                        ],
                      ),
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
                            child: Text(
                              "Sign In",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
  }
}
