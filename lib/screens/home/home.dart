import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/authenticate/convert/convert.dart';
import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/screens/home/tabs/tabs.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:blok_p1/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
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
      value: DatabaseService(userId: firebaseUser.uid).streamUser(),
      builder: (context, child) {
        final User user = Provider.of<User>(context);
        Tabs tabs = Tabs(
            serverEnabled: user != null ? user.serverEnabled : false,
            onServerEnabled: onServerEnabled);

        print(tabs.item(_tabIndex).label);

        return tabs.item(_tabIndex) == null
            ? Loading
            : Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, tabs.floatingRoutes()[_tabIndex]);
                  },
                  child: Icon(Icons.add),
                ),
                appBar: AppBar(
                  title: tabs.item(_tabIndex).title,
                  actions: <Widget>[
                    FlatButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, Convert.route);
                        },
                        icon: Icon(Icons.arrow_circle_up),
                        label: Text('Convert')),
                    FlatButton.icon(
                        onPressed: () async {
                          await _auth.signOut();
                        },
                        icon: Icon(Icons.person),
                        label: Text('Logout')),
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
