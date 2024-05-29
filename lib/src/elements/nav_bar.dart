import 'package:fedi_match/src/views/account_list_view.dart';
import 'package:fedi_match/src/views/matches_list_view.dart';
import 'package:fedi_match/src/views/settings_view.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final String? name;

  NavBar(this.name);

  final Map<String, (String routeName, IconData icon)> routeNames = {
    'Home': (AccountListView.routeName, Icons.home),
    'Likes & Matches': (MatchesListView.routeName, Icons.favorite),
    'Settings': (SettingsView.routeName, Icons.settings),
  };

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: name == null
          ? 0
          : routeNames.values.toList().indexOf(routeNames[name]!),
      onTap: (int index) {
        if (name == null) {
          return;
        }

        if (index == routeNames.keys.toList().indexOf(name!)) {
          return;
        }

        if (index == routeNames.keys.toList().indexOf('Home')) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          return;
        }

        Navigator.pushNamed(context, routeNames.values.elementAt(index).$1);
      },
      items: routeNames.keys.map((String name) {
        return BottomNavigationBarItem(
          icon: Icon(routeNames[name]!.$2),
          label: name,
        );
      }).toList(),
    );
  }
}
