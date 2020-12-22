import 'package:blok_p1/screens/home/tabs/followed/followed.dart';
import 'package:blok_p1/screens/home/tabs/owned/owned.dart';
import 'package:flutter/material.dart';

class Tabs {
  final List<Map<String, dynamic>> _tabs = [
    // if the user is not email verified, don't show the calendars tab.
    {
      'title': Text('Calendars'),
      'page': OwnedCalendars(),
      'icon': Icon(Icons.calendar_today),
      'label': 'Calendars',
      'addRoute': '/calendar/create',
    },
    {
      'title': Text('Events'),
      'page': FollowedCalendars(),
      'icon': Icon(Icons.event_note),
      'label': 'Events',
      'addRoute': '/calendar/join',
    }
  ];

  Map<String, dynamic> item(int index) {
    return _tabs[index];
  }

  List<dynamic> routes() {
    return _tabs.map((element) => element['addRoute']).toList();
  }

  List<BottomNavigationBarItem> navItems() {
    return _tabs.map((element) {
      return BottomNavigationBarItem(
          icon: element['icon'], label: element['label']);
    }).toList();
  }
}
