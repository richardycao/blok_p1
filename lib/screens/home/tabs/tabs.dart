import 'package:blok_p1/screens/calendar/create_calendar/create_calendar.dart';
import 'package:blok_p1/screens/calendar/join_calendar/join_calendar.dart';
import 'package:blok_p1/screens/home/tabs/followed_tab/followed_tab.dart';
import 'package:blok_p1/screens/home/tabs/owned_tab/owned_tab.dart';
import 'package:flutter/material.dart';

class Tabs {
  final List<Tab> _tabs = [
    // if the user is not email verified, don't show the calendars tab.
    Tab(
      title: Text('Calendars'),
      page: OwnedCalendars(),
      icon: Icon(Icons.calendar_today),
      label: 'Calendars',
      floatingRoute: CreateCalendar.route,
    ),
    Tab(
      title: Text('Events'),
      page: FollowedCalendars(),
      icon: Icon(Icons.event_note),
      label: 'Events',
      floatingRoute: JoinCalendar.route,
    ),
    Tab(
      title: Text('Profile'),
      page: Text('nothing here for now'),
      icon: Icon(Icons.person),
      label: 'Profile',
      floatingRoute: '/',
    ),
  ];

  // get data for a single tab
  Tab item(int index) {
    return _tabs[index];
  }

  // get all floating button routes for the tabs
  List<String> floatingRoutes() {
    return _tabs.map((element) => element.floatingRoute).toList();
  }

  // get all the navigation bar items for the tabs
  List<BottomNavigationBarItem> navItems() {
    return _tabs.map((element) {
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

  Tab({this.title, this.page, this.icon, this.label, this.floatingRoute});
}
