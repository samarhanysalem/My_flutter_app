import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../../auth/view/confirm_sign_out.dart';

/// Profile — a minimal placeholder: the signed-in patient's identity and a
/// sign-out action. More (edit profile, settings, etc.) can come later.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.displayName?.trim();
    final initialSource = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : user?.email;
    final initial = (initialSource == null || initialSource.isEmpty)
        ? '?'
        : initialSource[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.screenGround,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.navProfile, style: AppTheme.screenTitle),
                  const SizedBox(height: AppTheme.spacing24),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentTint,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            initial,
                            style: AppTheme.heading.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        if (displayName != null && displayName.isNotEmpty)
                          Text(displayName, style: AppTheme.cardTitle),
                        if (user?.email != null) ...[
                          const SizedBox(height: AppTheme.spacing2),
                          Text(user!.email!, style: AppTheme.subtitle),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing28),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: () => confirmSignOut(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout,
                        size: 18,
                        color: AppTheme.ink,
                      ),
                      label: Text(loc.signOut, style: AppTheme.body),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
