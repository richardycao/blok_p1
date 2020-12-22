import 'package:flutter/material.dart';

class OwnedCalendars extends StatefulWidget {
  final String title = 'Calendars';
  final String tabName = 'Calendars';

  @override
  _OwnedCalendarsState createState() => _OwnedCalendarsState();
}

class _OwnedCalendarsState extends State<OwnedCalendars> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('owned calendars'),
    );
  }
}
