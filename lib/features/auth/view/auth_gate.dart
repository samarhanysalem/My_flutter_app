import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/view/home_view.dart';
import 'auth_provider.dart';
import 'sign_in_view.dart';

/// Shows the sign-in flow or the authenticated app depending on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
            return const SignInView();
          case AuthStatus.authenticated:
            return const HomeView();
        }
      },
    );
  }
}
