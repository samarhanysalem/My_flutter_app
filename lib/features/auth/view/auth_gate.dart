import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../navigation/main_nav_shell.dart';
import '../../../common/repositories/appointment_repository.dart';
import '../../../common/repositories/profile_repository.dart';
import 'auth_provider.dart';
import 'login_view.dart';

/// Shows the sign-in flow or the authenticated app depending on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    AppointmentRepository? appointmentRepository,
    ProfileRepository? profileRepository,
  }) : _appointmentRepository = appointmentRepository,
       _profileRepository = profileRepository;

  final AppointmentRepository? _appointmentRepository;
  final ProfileRepository? _profileRepository;

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
              appointmentRepository: _appointmentRepository,
              profileRepository: _profileRepository,
            );
        }
      },
    );
  }
}
