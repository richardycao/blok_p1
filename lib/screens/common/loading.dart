import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final bool blank;
  Loading({this.blank = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: blank
              ? Text('')
              : SpinKitCircle(
                  color: Colors.blue,
                  size: 100.0,
                )),
    );
  }
}
