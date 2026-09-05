import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_colors.dart';

/// Labeled input matching the design handoff's field spec: 12px secondary
/// label, 6px gap, 46px-tall input with an 8px-radius border that turns
/// accent-colored on focus.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: AuthColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: Key('authField_$label'),
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          validator: validator,
          style: GoogleFonts.dmSans(fontSize: 14, color: AuthColors.ink),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            filled: true,
            fillColor: AuthColors.surface,
            border: _border(AuthColors.border),
            enabledBorder: _border(AuthColors.border),
            focusedBorder: _border(AuthColors.accent),
            errorBorder: _border(Theme.of(context).colorScheme.error),
            focusedErrorBorder: _border(Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}
