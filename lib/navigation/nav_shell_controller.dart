import 'package:flutter/foundation.dart';

import '../common/models/appointment.dart';

enum MainTab { home, appointments, profile }

/// Owns which of the three bottom-nav tabs is selected, and — since
/// switching to the Appointments tab can be triggered from inside another
/// tab (Home's "View details" on the upcoming-appointment card) rather
/// than only from the nav bar itself — which appointment (if any) that
/// tab should show. Provided once, above `MainNavShell`'s tabs, so any
/// descendant can request a tab switch without prop-threading a callback
/// down through Home's widget tree.
class NavShellController extends ChangeNotifier {
  MainTab _selectedTab = MainTab.home;
  MainTab get selectedTab => _selectedTab;

  Appointment? _appointmentToShow;
  Appointment? get appointmentToShow => _appointmentToShow;

  void selectTab(MainTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    if (tab != MainTab.appointments) _appointmentToShow = null;
    notifyListeners();
  }

  /// Switches to the Appointments tab and has it show [appointment] — the
  /// "View details" flow from Home's upcoming-appointment card.
  void showAppointmentDetails(Appointment appointment) {
    _appointmentToShow = appointment;
    _selectedTab = MainTab.appointments;
    notifyListeners();
  }
}
