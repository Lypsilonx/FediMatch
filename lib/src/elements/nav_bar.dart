import 'package:fedi_match/src/views/account_list_view.dart';
import 'package:fedi_match/src/views/matches_list_view.dart';
import 'package:fedi_match/src/views/settings_view.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final String? name;

  NavBar(this.name);

  final Map<String, (String routeName, IconData icon)> routeNames = {
    'Home': (AccountListView.routeName, Icons.home),
    'Matches': (MatchesListView.routeName, Icons.favorite),
    'Settings': (SettingsView.routeName, Icons.settings),
  };

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: name == null
          ? 0
          : routeNames.values.toList().indexOf(routeNames[name]!),
      onTap: (int index) {
        Navigator.pushReplacementNamed(
            context, routeNames.values.elementAt(index).$1);
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
// ButtonBar(
                //   alignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     IconButton(
                //       icon: const Icon(Icons.home),
                //       onPressed: () {
                //         Navigator.pushReplacementNamed(
                //             context, AccountListView.routeName);
                //       },
                //       isSelected:
                //           routeSettings.name == AccountListView.routeName,
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.favorite),
                //       onPressed: () {
                //         Navigator.pushReplacementNamed(
                //             context, MatchesListView.routeName);
                //       },
                //       isSelected:
                //           routeSettings.name == MatchesListView.routeName,
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.account_circle),
                //       onPressed: () {
                //         // TODO: implement account view
                //       },
                //       isSelected: routeSettings.name == false,
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.settings),
                //       onPressed: () {
                //         Navigator.pushReplacementNamed(
                //             context, SettingsView.routeName);
                //       },
                //       isSelected:
                //           routeSettings.name == SettingsView.routeName,
                //     ),
                //   ],
                // ),