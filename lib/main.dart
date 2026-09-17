import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/locale_provider.dart';
import 'features/auth/services/auth_repository.dart';
import 'features/auth/view/auth_gate.dart';
import 'features/auth/view/auth_provider.dart';
import 'features/home/services/appointment_service.dart';
import 'features/profile/services/profile_service.dart';
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
    AppointmentService? appointmentService,
    ProfileService? profileService,
  }) : _authRepository = authRepository,
       _appointmentService = appointmentService,
       _profileService = profileService;

  final AuthRepository? _authRepository;
  final AppointmentService? _appointmentService;
  final ProfileService? _profileService;

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
            appointmentService: _appointmentService,
            profileService: _profileService,
          ),
        ),
      ),
    );
  }
}
