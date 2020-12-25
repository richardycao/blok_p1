import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String label;
  final Widget value;
  ProfileInfoCard({this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Row(
        children: [
          Text(label),
          SizedBox(
            width: 10.0,
          ),
          value,
        ],
      ),
    );
  }
}
