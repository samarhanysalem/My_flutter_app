import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// The "Search doctors, specialties" bar. Filtering is client-side — see
/// `HomeProvider.setSearchQuery` — so this just reports text changes.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 17, color: AppTheme.textPlaceholder),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: AppTheme.body,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search doctors, specialties',
                hintStyle: AppTheme.subtitle.copyWith(
                  color: AppTheme.textPlaceholder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
