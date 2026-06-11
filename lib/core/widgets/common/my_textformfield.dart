import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function()? onSuffixIconPressed;
  final int? maxLines;
  final void Function(String)? onChanged;

  const MyTextFormField({
    super.key,
    required this.controller,
    this.labelText,
    required this.hintText,
    this.obscureText = false,
    required this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: widget.prefixIcon,
              )
            : null,
        suffixIcon: widget.obscureText
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                  icon: Icon(
                    _isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            : (widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: IconButton(
                        icon: widget.suffixIcon!,
                        onPressed: widget.onSuffixIconPressed,
                      ),
                    )
                  : null),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
