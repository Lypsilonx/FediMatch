import 'package:fedi_match/src/views/account_list_view.dart';
import 'package:fedi_match/src/views/chats_list_view.dart';
import 'package:fedi_match/src/views/matches_list_view.dart';
import 'package:fedi_match/src/views/settings_view.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final String? name;

  NavBar(this.name);

  final Map<String, (String name, IconData icon)> routeNames = {
    AccountListView.routeName: ('Explore', Icons.search),
    MatchesListView.routeName: ('Matches', Icons.favorite),
    ChatsListView.routeName: ('Chats', Icons.chat),
    SettingsView.routeName: ('Settings', Icons.settings),
  };

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
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

        if (index == routeNames.keys.toList().indexOf('/')) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          return;
        }

        Navigator.pushNamed(context, routeNames.keys.elementAt(index));
      },
      items: routeNames.keys.map((String name) {
        return BottomNavigationBarItem(
          icon: Icon(routeNames[name]!.$2),
          label: routeNames[name]!.$1,
        );
      }).toList(),
    );
  }
}
