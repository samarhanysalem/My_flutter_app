import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/locale_provider.dart';
import 'common/repositories/auth_repository.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/auth/view/auth_provider.dart';
import 'common/repositories/appointment_repository.dart';
import 'common/repositories/profile_repository.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    AuthRepository? authRepository,
    AppointmentRepository? appointmentRepository,
    ProfileRepository? profileRepository,
  }) : _authRepository = authRepository,
       _appointmentRepository = appointmentRepository,
       _profileRepository = profileRepository;

  final AuthRepository? _authRepository;
  final AppointmentRepository? _appointmentRepository;
  final ProfileRepository? _profileRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authRepository: _authRepository ?? FirebaseAuthRepository(),
          ),
        ),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
          title: AppConfig.appName,
          theme: AppTheme.materialTheme,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AuthGate(
            appointmentRepository: _appointmentRepository,
            profileRepository: _profileRepository,
          ),
        ),
      ),
    );
  }
}
