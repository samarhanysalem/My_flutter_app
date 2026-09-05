import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_colors.dart';

/// Labeled input matching the design handoff's field spec: 12px secondary
/// label, 6px gap, 46px-tall input with an 8px-radius border that turns
/// accent-colored on focus. When [obscureText] is true, shows a show/hide
/// toggle rather than always hiding the input.
class AuthTextField extends StatefulWidget {
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

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscureText;

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
          widget.label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AuthColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: Key('authField_${widget.label}'),
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
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
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AuthColors.textSecondary,
                    ),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
