import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_colors.dart';

/// The 18x18 custom checkbox + terms copy from the Register screen design.
class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: value ? AuthColors.accent : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: value ? AuthColors.accent : AuthColors.checkboxBorder,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "I agree to the clinic's terms and privacy policy.",
              style: GoogleFonts.dmSans(
                fontSize: 12,
                height: 1.45,
                color: AuthColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
