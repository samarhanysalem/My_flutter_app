import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/models/appointment.dart';
import '../../../common/models/doctor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/nav_shell_controller.dart';
import '../../../theme/app_theme.dart';
import '../../auth/view/auth_provider.dart';
import '../../auth/view/confirm_sign_out.dart';
import '../../doctor_profile/view/doctor_profile_view.dart';
import '../services/appointment_service.dart';
import '../widgets/doctor_list.dart';
import '../widgets/home_greeting_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/specialty_shortcuts_row.dart';
import '../widgets/upcoming_appointment_card.dart';
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

  Future<void> _openDoctorProfile(BuildContext context, Doctor doctor) async {
    final confirmationMessage = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => DoctorProfileView(doctor: doctor)),
    );
    if (confirmationMessage == null || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(confirmationMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final patientId = context.read<AuthProvider>().user?.uid;
    return ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider(
        appointmentService: widget._appointmentService ??
            FirestoreAppointmentService(),
        patientId: patientId,
      ),
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();
          return Scaffold(
            backgroundColor: AppTheme.screenGround,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  // A CustomScrollView so the doctor list below can be a
                  // real SliverList — built lazily, only for on-screen
                  // cards — rather than a shrinkWrap ListView nested in a
                  // SingleChildScrollView, which builds every card up
                  // front regardless of what's visible.
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacing20,
                          AppTheme.spacing20,
                          AppTheme.spacing20,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HomeGreetingHeader(
                                user: authProvider.user,
                                onAvatarTap: () => confirmSignOut(context),
                              ),
                              const SizedBox(height: AppTheme.spacing20),
                              // Each section below is scoped to just the
                              // slice of HomeProvider it needs, so typing in
                              // the search bar (which changes on every
                              // keystroke) only rebuilds the doctor list,
                              // not the greeting or this bar itself.
                              Selector<HomeProvider, List<Doctor>>(
                                selector: (_, provider) => provider.allDoctors,
                                builder: (context, allDoctors, _) =>
                                    HomeSearchBar(
                                      doctors: allDoctors,
                                      onChanged: context
                                          .read<HomeProvider>()
                                          .setSearchQuery,
                                    ),
                              ),
                              Selector<HomeProvider, Appointment?>(
                                selector: (_, provider) =>
                                    provider.upcomingAppointment,
                                builder: (context, appointment, _) {
                                  // Hidden entirely with no upcoming
                                  // appointment — the layout collapses
                                  // straight from the search bar to the
                                  // specialty shortcuts below.
                                  if (appointment == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppTheme.spacing20,
                                    ),
                                    child: UpcomingAppointmentCard(
                                      appointment: appointment,
                                      onViewDetails: () => context
                                          .read<NavShellController>()
                                          .selectTab(MainTab.appointments),
                                      lookupDoctor: context
                                          .read<HomeProvider>()
                                          .getDoctor,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppTheme.spacing20),
                              Selector<HomeProvider, String?>(
                                selector: (_, provider) =>
                                    provider.selectedSpecialty,
                                builder: (context, selectedSpecialty, _) =>
                                    SpecialtyShortcutsRow(
                                      selectedSpecialty: selectedSpecialty,
                                      onSelect: context
                                          .read<HomeProvider>()
                                          .selectSpecialty,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacing20),
                              Text(
                                AppLocalizations.of(context)!.ourDoctors,
                                style: AppTheme.sectionTitle,
                              ),
                              const SizedBox(height: AppTheme.spacing12),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spacing20,
                          0,
                          AppTheme.spacing20,
                          AppTheme.spacing20,
                        ),
                        sliver: Selector<
                          HomeProvider,
                          (List<Doctor>, bool, bool, bool)
                        >(
                          selector: (_, provider) => (
                            provider.doctors,
                            provider.isLoading,
                            provider.hasError,
                            provider.hasActiveFilter,
                          ),
                          builder: (context, state, _) {
                            final (
                              doctors,
                              isLoading,
                              hasError,
                              hasActiveFilter,
                            ) = state;
                            return DoctorList(
                              doctors: doctors,
                              isLoading: isLoading,
                              hasError: hasError,
                              hasActiveFilter: hasActiveFilter,
                              onDoctorTap: (doctor) =>
                                  _openDoctorProfile(context, doctor),
                            );
                          },
                        ),
                      ),
                    ],
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
