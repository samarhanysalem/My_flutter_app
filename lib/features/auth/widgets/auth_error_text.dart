import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.dmSans(
        fontSize: 12,
        color: Theme.of(context).colorScheme.error,
      ),
      textAlign: TextAlign.center,
    );
  }
}
