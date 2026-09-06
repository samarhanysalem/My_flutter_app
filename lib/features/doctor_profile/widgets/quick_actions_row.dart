import 'package:flutter/material.dart';

import '../../../common/utils/not_available_yet.dart';
import '../../../theme/app_theme.dart';

class _QuickAction {
  const _QuickAction(this.label, this.icon);

  final String label;
  final IconData icon;
}

const _actions = [
  _QuickAction('Message', Icons.mail_outline),
  _QuickAction('Call', Icons.call_outlined),
  _QuickAction('Location', Icons.location_on_outlined),
];

/// Message / Call / Location shortcuts from the design handoff. None are
/// wired to a real feature yet, so each just surfaces a "not available
/// yet" notice, matching the same stub pattern used elsewhere in the app.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final action in _actions) ...[
          Expanded(
            child: InkWell(
              onTap: () => showNotAvailableYet(context, action.label),
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
                    Text(action.label, style: AppTheme.captionSecondary),
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
