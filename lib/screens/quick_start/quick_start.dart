import 'package:blok_p1/screens/authenticate/authenticate.dart';
import 'package:blok_p1/screens/quick_create_calendar.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:flutter/material.dart';

class QuickStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Quick start'),
        backgroundColor: Colors.black45,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
              onPressed: () async {
                // TODO: sign in with anon after quick create is finished so the
                // user isn't taken to the home screen if they press the back
                // button.
                // dynamic result = await _auth.signInAnon();
                // if (result == null) {
                //   print('Error signing in as anon');
                // }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QuickCreateCalendar()),
                );
              },
              child: Text('Create calendar')),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(onPressed: null, child: Text('Join calendar')),
          SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Authenticate()),
                );
              },
              child: Text('Have an account?')),
        ],
      ),
    );
  }
}
