import 'package:blok_p1/models/calendar.dart';
import 'package:flutter/material.dart';

class OwnedCalendarTile extends StatelessWidget {
  final Calendar calendar;
  OwnedCalendarTile({this.calendar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: null,
          title: Text(calendar.name),
          //subtitle: Text(calendar.description),
          onTap: () {
            //Navigator.pushNamed(context, routeName);
          },
        ),
      ),
    );
  }
}
