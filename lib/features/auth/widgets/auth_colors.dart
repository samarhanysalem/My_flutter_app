import 'package:flutter/material.dart';

/// Design tokens for the Sign in / Register screens, taken from the
/// "Doctor Appointment Screens" design handoff.
class AuthColors {
  const AuthColors._();

  static const accent = Color(0xFF4C6FD4);
  static const ink = Color(0xFF131316);
  static const textSecondary = Color(0xFF6A6A74);
  static const textPlaceholder = Color(0xFFA5A5AE);
  static const textDisabled = Color(0xFF8A8A93);
  static const surface = Colors.white;
  static const screenGround = Color(0xFFF6F6F7);
  static const border = Color(0xFFE6E6EA);
  static const divider = Color(0xFFE2E2E7);
  static const disabledFill = Color(0xFFDCDCE0);
  static const checkboxBorder = Color(0xFFD3D3DA);

  /// Darkened accent for pressed/hover states; the handoff gives this as a
  /// separate OKLCH value but a simple mix reproduces it closely enough.
  static Color get accentPressed => Color.lerp(accent, Colors.black, 0.12)!;
}
