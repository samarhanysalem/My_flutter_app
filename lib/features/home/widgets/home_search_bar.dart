import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/doctor.dart';

/// The "Search doctors, specialties" bar. Filtering is client-side — see
/// `HomeProvider.setSearchQuery` — and this also offers autocomplete
/// suggestions (distinct doctor names and specialties matching the typed
/// text) so a user can tap a match instead of typing the whole thing.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    super.key,
    required this.doctors,
    required this.onChanged,
  });

  /// The unfiltered doctor list, used only to build suggestions from.
  final List<Doctor> doctors;
  final ValueChanged<String> onChanged;

  static const int _maxSuggestions = 6;

  Iterable<String> _suggestionsFor(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const Iterable<String>.empty();
    final matches = <String>{};
    for (final doctor in doctors) {
      if (doctor.name.toLowerCase().contains(trimmed)) {
        matches.add(doctor.name);
      }
      if (doctor.specialty.toLowerCase().contains(trimmed)) {
        matches.add(doctor.specialty);
      }
    }
    return matches.take(_maxSuggestions);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<String>(
          optionsBuilder: (textEditingValue) =>
              _suggestionsFor(textEditingValue.text),
          onSelected: onChanged,
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return Container(
              height: 44,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing12,
              ),
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
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: onChanged,
                      onSubmitted: (_) => onSubmitted(),
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
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: 240,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing12,
                              vertical: AppTheme.spacing10,
                            ),
                            child: Text(option, style: AppTheme.body),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
