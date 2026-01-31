import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:chat_app/core/widgets/common/my_textformfield.dart';
import 'package:chat_app/core/widgets/common/mysnakebar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:chat_app/core/widgets/common/app_base_view.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthRepository>().sendPasswordResetEmail(_emailController.text.trim());
        if(!mounted) return;
        MySnackBar.show(context: context, title: "Email Sent", message: "Check your email to reset your password.", isError: false);
        Navigator.pop(context);
      } catch (e) {
        if(!mounted) return;
        MySnackBar.show(context: context, title: "Error", message: e.toString(), isError: true);
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseView(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Forgot Password"),
          leading: BackButton(color: Theme.of(context).colorScheme.onSurface),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Text("Reset Password", style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  const SizedBox(height: 8),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      "Enter your email to receive a password reset link.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: const Text("Send Reset Link"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
