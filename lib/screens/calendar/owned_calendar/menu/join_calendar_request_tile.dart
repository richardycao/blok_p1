import 'package:blok_p1/models/request.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';

class OwnedCalendarJoinCalendarRequestTile extends StatelessWidget {
  final Request request;
  final String approverUserId;
  OwnedCalendarJoinCalendarRequestTile({this.request, this.approverUserId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0), // padding outside the card
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            vertical: 10.0, horizontal: 30.0), // padding inside the card
        title: Row(
          children: [
            Text('join request'),
            FlatButton(
                onPressed: () {
                  DatabaseService()
                      .respondJoinCalendarRequest(approverUserId, request, 1);
                },
                child: Icon(Icons.check)),
            FlatButton(
                onPressed: () {
                  DatabaseService()
                      .respondJoinCalendarRequest(approverUserId, request, 0);
                },
                child: Icon(Icons.delete_forever)),
          ],
        ),
      ),
    );
  }
}
