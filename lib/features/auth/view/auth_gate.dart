import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../navigation/main_nav_shell.dart';
import '../../home/services/appointment_service.dart';
import '../../profile/services/profile_service.dart';
import 'auth_provider.dart';
import 'login_view.dart';

/// Shows the sign-in flow or the authenticated app depending on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    AppointmentService? appointmentService,
    ProfileService? profileService,
  }) : _appointmentService = appointmentService,
       _profileService = profileService;

  final AppointmentService? _appointmentService;
  final ProfileService? _profileService;

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, AuthStatus>(
      selector: (_, auth) => auth.status,
      builder: (context, status, _) {
        switch (status) {
          case AuthStatus.unknown:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.unauthenticated:
            return const LoginView();
          case AuthStatus.authenticated:
            return MainNavShell(
              appointmentService: _appointmentService,
              profileService: _profileService,
            );
        }
      },
    );
  }
}
