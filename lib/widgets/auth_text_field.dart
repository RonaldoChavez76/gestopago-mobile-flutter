import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.label,
    required this.icon,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleVisibility,
    this.validator,
    this.maxLength,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String label;
  final String? hintText;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        counterText: '',
        prefixIcon: Icon(icon),
        suffixIcon: onToggleVisibility == null
            ? null
            : IconButton(
                tooltip: obscureText
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
      ),
    );
  }
}
