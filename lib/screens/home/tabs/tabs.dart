import 'package:blok_p1/screens/calendar/create_calendar/create_calendar.dart';
import 'package:blok_p1/screens/calendar/join_calendar/join_calendar.dart';
import 'package:blok_p1/screens/home/tabs/followed_tab/followed_tab.dart';
import 'package:blok_p1/screens/home/tabs/owned_tab/owned_tab.dart';
import 'package:blok_p1/screens/home/tabs/profile_tab/profile_tab.dart';
import 'package:flutter/material.dart';

class Tabs {
  final bool serverEnabled;
  final Function onServerEnabled;
  List<Tab> _tabs;

  Tabs({this.serverEnabled, this.onServerEnabled}) {
    _tabs = [
      Tab(
        title: Text('Calendars'),
        page: OwnedCalendars(),
        icon: Icon(Icons.calendar_today),
        label: 'Calendars',
        floatingRoute: CreateCalendar.route,
        serverOnly: true,
      ),
      Tab(
        title: Text('Events'),
        page: FollowedCalendars(),
        icon: Icon(Icons.event_note),
        label: 'Events',
        floatingRoute: JoinCalendar.route,
        serverOnly: false,
      ),
      Tab(
        title: Text('Profile'),
        page: Profile(
          onServerEnabled: onServerEnabled,
        ),
        icon: Icon(Icons.person),
        label: 'Profile',
        floatingRoute: '/',
        serverOnly: false,
      ),
    ];
  }

  List<Tab> visibleTabs() {
    if (serverEnabled == false) {
      return _tabs.where((tab) => !tab.serverOnly).toList();
    }
    return _tabs;
  }

  // get data for a single tab
  Tab item(int index) {
    return visibleTabs()[index];
  }

  // get all floating button routes for the tabs
  List<String> floatingRoutes() {
    return visibleTabs().map((element) => element.floatingRoute).toList();
  }

  // get all the navigation bar items for the tabs
  List<BottomNavigationBarItem> navItems() {
    return visibleTabs().map((element) {
      return BottomNavigationBarItem(icon: element.icon, label: element.label);
    }).toList();
  }
}

class Tab {
  final Widget title;
  final Widget page;
  final Widget icon;
  final String label;
  final String floatingRoute;
  final bool serverOnly;

  Tab(
      {this.title,
      this.page,
      this.icon,
      this.label,
      this.floatingRoute,
      this.serverOnly});
}
