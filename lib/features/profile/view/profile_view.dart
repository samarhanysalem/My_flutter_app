import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../../auth/view/confirm_sign_out.dart';
import '../services/profile_service.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/profile_action_tile.dart';
import '../widgets/profile_avatar_header.dart';
import '../widgets/profile_edit_form.dart';
import 'profile_provider.dart';

/// Profile: the signed-in patient's identity, editable name/phone, and the
/// account actions (change password, delete account, log out).
class ProfileView extends StatelessWidget {
  const ProfileView({super.key, this.profileService});

  /// Injectable for tests, so they never talk to real Firebase.
  final ProfileService? profileService;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return ChangeNotifierProvider<ProfileProvider>(
      create: (_) => ProfileProvider(
        profileService: profileService ?? FirestoreProfileService(),
        uid: user?.uid,
        email: user?.email,
      ),
      child: const _ProfileScaffold(),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final profileProvider = context.watch<ProfileProvider>();

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
                  ProfileAvatarHeader(
                    displayName: profileProvider.isLoading
                        ? user?.displayName
                        : profileProvider.fullName,
                    email: user?.email,
                  ),
                  const SizedBox(height: AppTheme.spacing28),
                  if (profileProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (profileProvider.hasLoadError)
                    Center(
                      child: Text(
                        loc.loadProfileError,
                        style: AppTheme.subtitle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    // Only ever built once loading has finished, so this is
                    // the one and only construction of this State — a later
                    // rebuild here (e.g. after a successful save changes
                    // profileProvider.fullName/phone) updates its widget
                    // without remounting, leaving the field controllers
                    // (and whatever the patient is mid-typing) alone.
                    ProfileEditForm(
                      initialFullName: profileProvider.fullName,
                      initialPhone: profileProvider.phone,
                    ),
                  const SizedBox(height: AppTheme.spacing24),
                  const Divider(color: AppTheme.divider, height: 1),
                  ProfileActionTile(
                    icon: Icons.lock_outline,
                    label: loc.changePassword,
                    onTap: () => showChangePasswordDialog(context, profileProvider),
                  ),
                  ProfileActionTile(
                    icon: Icons.delete_outline,
                    label: loc.deleteAccount,
                    color: AppTheme.error,
                    onTap: () => showDeleteAccountDialog(context, profileProvider),
                  ),
                  ProfileActionTile(
                    icon: Icons.logout,
                    label: loc.signOut,
                    onTap: () => confirmSignOut(context),
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
