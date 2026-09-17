import 'package:flutter/foundation.dart';

enum MainTab { home, appointments, profile }

/// Owns which of the three bottom-nav tabs is selected. Switching tabs can
/// be triggered from inside another tab (Home's "View details" on the
/// upcoming-appointment card, My appointments' "Book now" empty state)
/// rather than only from the nav bar itself, so this is provided once above
/// `MainNavShell`'s tabs — any descendant can request a tab switch without
/// prop-threading a callback down through that tab's widget tree.
class NavShellController extends ChangeNotifier {
  MainTab _selectedTab = MainTab.home;
  MainTab get selectedTab => _selectedTab;

  void selectTab(MainTab tab) {
    if (tab == _selectedTab) return;
    _selectedTab = tab;
    notifyListeners();
  }
}
