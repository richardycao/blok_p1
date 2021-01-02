import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/screens/home/home_menu.dart';
import 'package:blok_p1/screens/home/tabs/tabs.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tabIndex = 0;

  void onTabTap(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void onServerEnabled(bool enabled) {
    setState(() {
      _tabIndex += enabled ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseUser firebaseUser = Provider.of<FirebaseUser>(context);

    return StreamProvider<User>.value(
      value: DatabaseService().streamUser(firebaseUser.uid),
      builder: (context, child) {
        final User user = Provider.of<User>(context);
        Tabs tabs = Tabs(
            serverEnabled: user != null ? user.serverEnabled : false,
            onServerEnabled: onServerEnabled);

        return tabs.item(_tabIndex) == null
            ? Loading
            : Scaffold(
                drawer: HomeMenu(),
                appBar: AppBar(
                  title: tabs.item(_tabIndex).title,
                  actions: <Widget>[
                    if (_tabIndex != 2)
                      FlatButton(
                          onPressed: () {
                            var routes = tabs.floatingRoutes();
                            if (routes[_tabIndex] != null)
                              Navigator.pushNamed(context, routes[_tabIndex]);
                          },
                          child: Icon(Icons.add))
                  ],
                ),
                body: tabs.item(_tabIndex).page,
                bottomNavigationBar: BottomNavigationBar(
                  onTap: onTabTap,
                  currentIndex: _tabIndex,
                  items: tabs.navItems(),
                ),
              );
      },
    );
  }
}
