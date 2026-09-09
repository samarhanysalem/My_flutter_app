import 'package:flutter/material.dart';

import '../../../common/utils/not_available_yet.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class _QuickAction {
  const _QuickAction(this.id, this.icon);

  /// Stable identifier used to look up the localized label — see
  /// [_labelFor]. Not shown to the user.
  final String id;
  final IconData icon;
}

const _actions = [
  _QuickAction('message', Icons.mail_outline),
  _QuickAction('call', Icons.call_outlined),
  _QuickAction('location', Icons.location_on_outlined),
];

String _labelFor(AppLocalizations loc, String id) {
  switch (id) {
    case 'message':
      return loc.messageAction;
    case 'call':
      return loc.callAction;
    case 'location':
      return loc.locationAction;
  }
  throw ArgumentError('Unknown quick action id: $id');
}

/// Message / Call / Location shortcuts from the design handoff. None are
/// wired to a real feature yet, so each just surfaces a "not available
/// yet" notice, matching the same stub pattern used elsewhere in the app.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        for (final action in _actions) ...[
          Expanded(
            child: InkWell(
              onTap: () =>
                  showNotAvailableYet(context, _labelFor(loc, action.id)),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing12,
                  horizontal: AppTheme.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action.icon, size: 18, color: AppTheme.primary),
                    const SizedBox(height: AppTheme.spacing6),
                    Text(_labelFor(loc, action.id), style: AppTheme.captionSecondary),
                  ],
                ),
              ),
            ),
          ),
          if (action != _actions.last) const SizedBox(width: AppTheme.spacing10),
        ],
      ],
    );
  }
}
