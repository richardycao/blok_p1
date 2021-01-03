import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text('item'),
            onTap: () => {},
          ),
          ListTile(
            title: Text('item'),
            onTap: () => {},
          )
        ],
      ),
    );
  }
}
