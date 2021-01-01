import 'package:blok_p1/models/request.dart';
import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';

class FollowedCalendarJoinTimeSlotRequestsTile extends StatelessWidget {
  final Request request;
  final String approverId;
  FollowedCalendarJoinTimeSlotRequestsTile({this.request, this.approverId});

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
            Text('time slot req'),
            FlatButton(
                onPressed: () {
                  DatabaseService(
                          userId: approverId, requestId: request.requestId)
                      .respondRequestJoinTimeSlot(1);
                },
                child: Icon(Icons.check)),
            FlatButton(
                onPressed: () {
                  DatabaseService(
                          userId: approverId, requestId: request.requestId)
                      .respondRequestJoinTimeSlot(0);
                },
                child: Icon(Icons.delete_forever)),
          ],
        ),
      ),
    );
  }
}
