import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../../doctor_profile/view/doctor_profile_view.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';
import '../widgets/doctor_list.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/specialty_shortcuts_row.dart';
import 'home_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, AppointmentService? appointmentService})
    : _appointmentService = appointmentService;

  final AppointmentService? _appointmentService;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final StreamSubscription<String> _profileWarningSubscription;

  @override
  void initState() {
    super.initState();
    // A profile save (display name / Firestore doc) from sign-up can still
    // be in flight when this screen appears, since it's non-blocking and
    // runs after the account is already created. Surface it here rather
    // than on the (likely already popped) register screen.
    _profileWarningSubscription = context
        .read<AuthProvider>()
        .profileWarnings
        .listen((message) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        });
  }

  @override
  void dispose() {
    _profileWarningSubscription.cancel();
    super.dispose();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await authProvider.signOut();
    }
  }

  void _openDoctorProfile(BuildContext context, Doctor doctor) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DoctorProfileView(doctor: doctor)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider(
        appointmentService: widget._appointmentService ??
            FirestoreAppointmentService(),
      ),
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          final homeProvider = context.watch<HomeProvider>();
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
                        HomeGreetingHeader(
                          user: authProvider.user,
                          onAvatarTap: () => _confirmSignOut(context),
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        HomeSearchBar(onChanged: homeProvider.setSearchQuery),
                        const SizedBox(height: AppTheme.spacing20),
                        SpecialtyShortcutsRow(
                          selectedSpecialty: homeProvider.selectedSpecialty,
                          onSelect: homeProvider.selectSpecialty,
                        ),
                        const SizedBox(height: AppTheme.spacing20),
                        Text('Nearby doctors', style: AppTheme.sectionTitle),
                        const SizedBox(height: AppTheme.spacing12),
                        DoctorList(
                          doctors: homeProvider.doctors,
                          isLoading: homeProvider.isLoading,
                          errorMessage: homeProvider.errorMessage,
                          hasActiveFilter: homeProvider.hasActiveFilter,
                          onDoctorTap: (doctor) =>
                              _openDoctorProfile(context, doctor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
