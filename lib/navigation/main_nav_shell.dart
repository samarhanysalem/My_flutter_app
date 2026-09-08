import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/appointments/view/my_appointments_view.dart';
import '../features/home/services/appointment_service.dart';
import '../features/home/view/home_view.dart';
import '../features/profile/view/profile_view.dart';
import 'main_bottom_nav_bar.dart';
import 'nav_shell_controller.dart';

/// The app's persistent navigation shell: Home, Appointments, and Profile
/// behind one bottom nav bar. Wraps the three main screens rather than
/// living inside any one of them, so the bar stays visible while switching
/// tabs (an `IndexedStack` also keeps each tab's state — e.g. Home's
/// search/filters — alive when it's not the active one).
class MainNavShell extends StatelessWidget {
  const MainNavShell({super.key, this.appointmentService});

  /// Injectable for tests, so they never talk to real Firestore.
  final AppointmentService? appointmentService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavShellController>(
      create: (_) => NavShellController(),
      child: Builder(
        builder: (context) {
          final nav = context.watch<NavShellController>();
          return Scaffold(
            body: IndexedStack(
              index: nav.selectedTab.index,
              children: [
                HomeView(appointmentService: appointmentService),
                MyAppointmentsView(appointment: nav.appointmentToShow),
                const ProfileView(),
              ],
            ),
            bottomNavigationBar: MainBottomNavBar(
              selected: nav.selectedTab,
              onSelect: nav.selectTab,
            ),
          );
        },
      ),
    );
  }
}
