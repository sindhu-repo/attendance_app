import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final AutovalidateMode autovalidateMode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
    this.autofocus = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.sentences,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      autofocus: autofocus,
      enabled: enabled,
      textCapitalization: textCapitalization,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
