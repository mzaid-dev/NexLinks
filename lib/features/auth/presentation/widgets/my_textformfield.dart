import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function()? onSuffixIconPressed;
  const MyTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    required this.keyboardType ,
    required this.prefixIcon,
    required this.validator,
    this.suffixIcon,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        hintText: hintText,
        suffixIcon:  suffixIcon != null
            ? IconButton(
          icon: suffixIcon!,
          onPressed: onSuffixIconPressed,
        )
            : null,
      ),
      validator: validator
    );
  }
}
