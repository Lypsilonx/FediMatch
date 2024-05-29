import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavBar("Settings"),
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(controller: ScrollController(), children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme'),
                DropdownButton<ThemeMode>(
                  underline: Container(),
                  value: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextButton(
              style: new ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.error)),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Matcher Data'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'Are you sure you want to delete all Matcher data?'),
                            Text(
                                "You will loose ${Matcher.liked.length} liked accounts, ${Matcher.disliked.length} disliked accounts and ${Matcher.superliked.length} superliked accounts."),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            Matcher.clear();
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
                "Clear Matcher data",
              ),
            ),
            TextButton(
              style: new ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.error)),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Matcher Data'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                'Are you sure you want to log out and delete all Matcher data?'),
                            Text(
                                "You will loose ${Matcher.liked.length} liked accounts, ${Matcher.disliked.length} disliked accounts and ${Matcher.superliked.length} superliked accounts."),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Matcher.clear();
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
                "Logout",
              ),
            ),
          ]),
        ));
  }
}
