import 'package:blok_p1/screens/authenticate/authenticate.dart';
import 'package:blok_p1/screens/quick_start/quick_create_calendar.dart';
import 'package:flutter/material.dart';

class QuickStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick start'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 120.0),
        child: Form(
          child: Column(
            children: [
              Text('Blok', style: TextStyle(fontSize: 50)),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                  onPressed: () {
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
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Authenticate()),
                    );
                  },
                  child: Text('Have an account?')),
            ],
          ),
        ),
      ),
    );
  }
}
