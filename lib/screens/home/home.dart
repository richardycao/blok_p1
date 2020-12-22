import 'package:blok_p1/screens/home/tabs/tabs.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  Tabs tabs = Tabs();
  int _tabIndex = 0;

  void onTabTap(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, tabs.routes()[_tabIndex].toString());
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: tabs.item(_tabIndex)['title'],
        actions: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('Logout')),
          FlatButton.icon(
              onPressed: () {
                // go to convert page (almost same as register page)
              },
              icon: Icon(Icons.arrow_circle_up),
              label: Text('Convert')),
        ],
      ),
      body: tabs.item(_tabIndex)['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTap,
        currentIndex: _tabIndex,
        items: tabs.navItems(),
      ),
    );
  }
}
