import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'features/auth/services/auth_repository.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/auth/view/auth_provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, AuthRepository? authRepository})
    : _authRepository = authRepository;

  final AuthRepository? _authRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(
        authRepository: _authRepository ?? FirebaseAuthRepository(),
      ),
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.materialTheme,
        home: const AuthGate(),
      ),
    );
  }
}
