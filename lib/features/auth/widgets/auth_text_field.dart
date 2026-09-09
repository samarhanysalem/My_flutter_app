import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// Labeled input matching the design handoff's field spec: 12px secondary
/// label, 6px gap, 46px-tall input with an 8px-radius border that turns
/// accent-colored on focus. When [obscureText] is true, shows a show/hide
/// toggle rather than always hiding the input.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
  });

  /// A stable, non-localized identifier for this field (e.g. 'email'),
  /// used to build a widget [Key] that stays the same across languages —
  /// unlike [label], which is user-facing, localized text.
  final String fieldKey;
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
    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: AppTheme.fieldLabel),
        const SizedBox(height: AppTheme.spacing6),
        TextFormField(
          key: Key('authField_${widget.fieldKey}'),
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          style: AppTheme.body,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            filled: true,
            fillColor: AppTheme.surface,
            border: _border(AppTheme.border),
            enabledBorder: _border(AppTheme.border),
            focusedBorder: _border(AppTheme.primary),
            errorBorder: _border(Theme.of(context).colorScheme.error),
            focusedErrorBorder: _border(Theme.of(context).colorScheme.error),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    tooltip: _obscured
                        ? AppLocalizations.of(context)!.showPassword
                        : AppLocalizations.of(context)!.hidePassword,
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
