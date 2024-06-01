import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/src/views/login_view.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';
import '../settings/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  void Update() => setState(() {
        Util.executeWhenOK(
            Mastodon.Update(SettingsController.instance.userInstanceName,
                SettingsController.instance.accessToken),
            context);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar("Settings"),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: ScrollController(),
          children: [
            AccountView(Mastodon.instance.self, edgeInset: 0),
            SizedBox(height: 20),

            // Theme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Theme'),
                DropdownButton<ThemeMode>(
                  underline: Container(),
                  value: SettingsController.instance.themeMode,
                  onChanged: SettingsController.instance.updateThemeMode,
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

            // Show non-opt-in accounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Show non-opt-in accounts'),
                Switch(
                  value: SettingsController.instance.showNonOptInAccounts,
                  onChanged: (bool value) {
                    if (value) {
                      Util.popUpDialog(
                          context,
                          "Show non-opt-in accounts",
                          "Showing non-opt-in accounts will allow you to see accounts that have not opted in to FediMatch."
                              "\nThis will allow you to see more accounts, but you will not be able to match with them."
                              "\nPeople who have not opted in to FediMatch might not want you to find their account and/or chat with them."
                              "\n\nDo you want to show non-opt-in accounts?",
                          "Acknowledge", () {
                        SettingsController.instance
                            .updateShowNonOptInAccounts(value);
                        Update();
                      });
                    }
                    SettingsController.instance
                        .updateShowNonOptInAccounts(value);
                    Update();
                  },
                ),
              ],
            ),

            // Opt-in
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Opt-in to FediMatch'),
                Switch(
                  value: Mastodon.instance.self.hasFediMatchField(),
                  onChanged: (bool value) {
                    if (value) {
                      Util.executeWhenOK(
                        Mastodon.optInToFediMatch(
                            SettingsController.instance.userInstanceName,
                            SettingsController.instance.accessToken),
                        context,
                        onOK: Update,
                      );
                    } else {
                      Util.executeWhenOK(
                        Mastodon.optOutOfFediMatch(
                            SettingsController.instance.userInstanceName,
                            SettingsController.instance.accessToken),
                        context,
                        onOK: Update,
                      );
                    }
                  },
                ),
              ],
            ),

            // Opt-in Matching
            Mastodon.instance.self.hasFediMatchField()
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('FediMatch Matching'),
                      Switch(
                        value: Mastodon.instance.self.hasFediMatchKeyField(),
                        onChanged: (bool value) {
                          if (value) {
                            Util.popUpDialog(
                              context,
                              "FediMatch Matching",
                              "FediMatch Matching will post your likes and superlikes as encrypted unlisted toots."
                                  "\nThis will allow other FediMatch users (only the ones affected by each like or superlike) to make a match with you."
                                  "\n\nDo you want to opt-in to FediMatch Matching?",
                              "Acknowledge",
                              () => Util.executeWhenOK(
                                Mastodon.optInToFediMatchMatching(
                                    SettingsController
                                        .instance.userInstanceName,
                                    SettingsController.instance.accessToken),
                                context,
                                onOK: Update,
                              ),
                            );
                          } else {
                            Util.executeWhenOK(
                              Mastodon.optOutOfFediMatchMatching(
                                  SettingsController.instance.userInstanceName,
                                  SettingsController.instance.accessToken),
                              context,
                              onOK: Update,
                            );
                          }
                        },
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 20),

            // Clear Matcher data
            TextButton(
              style: new ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.error)),
              onPressed: () {
                Util.popUpDialog(
                  context,
                  "Delete Matcher Data",
                  "Are you sure you want to delete all Matcher data?"
                      "\nYou will loose ${Matcher.liked.length} liked accounts, ${Matcher.disliked.length} disliked accounts and ${Matcher.superliked.length} superliked accounts.",
                  "Delete",
                  () {
                    Matcher.clear();
                    Update();
                  },
                );
              },
              child: Text(
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
                "Clear Matcher data",
              ),
            ),

            // Logout
            TextButton(
              style: new ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.error)),
              onPressed: () {
                Util.popUpDialog(
                  context,
                  "Logout",
                  "Are you sure you want to log out?"
                      "\nYou will loose ${Matcher.liked.length} liked accounts, ${Matcher.disliked.length} disliked accounts and ${Matcher.superliked.length} superliked accounts.",
                  "Logout",
                  () async {
                    Matcher.clear();
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                    await Mastodon.Logout(SettingsController.instance);
                    Navigator.pushReplacementNamed(
                        context, LoginView.routeName);
                  },
                );
              },
              child: Text(
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
                "Logout",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
