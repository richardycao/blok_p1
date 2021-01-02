import 'package:blok_p1/models/user.dart';
import 'package:blok_p1/screens/authenticate/convert/convert.dart';
import 'package:blok_p1/screens/common/loading.dart';
import 'package:blok_p1/screens/home/tabs/profile_tab/profile_info_card.dart';
import 'package:blok_p1/services/auth.dart';
import 'package:blok_p1/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final Function onServerEnabled;
  Profile({this.onServerEnabled});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    if (user == null) {
      return Loading(
        blank: true,
      );
    }

    return Column(
      children: [
        ProfileInfoCard(
          label: 'id:',
          value: Text(user.userId ?? "n/a"),
        ),
        ProfileInfoCard(
          label: 'name:',
          value: Text(user.displayName ?? "n/a"),
        ),
        ProfileInfoCard(label: 'email:', value: Text(user.email ?? "n/a")),
        if (user.email != null)
          ProfileInfoCard(
            label: 'client/server',
            value: Switch(
                value: user.serverEnabled,
                onChanged: (result) async {
                  setState(() {
                    widget.onServerEnabled(result);
                  });
                  await DatabaseService()
                      .updateUser(user.userId, serverEnabled: result);
                }),
          ),
        if (user.email == null)
          FlatButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, Convert.route);
              },
              icon: Icon(Icons.arrow_circle_up),
              label: Text('Convert to permanent account')),
        if (user.email != null)
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(Icons.person),
              label: Text('Logout')),
      ],
    );
  }
}
