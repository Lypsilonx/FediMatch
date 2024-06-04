import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/dismissable_list.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/src/views/login_view.dart';
import 'package:fedi_match/util.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  void Update() => Util.executeWhenOK(
        Mastodon.Update(SettingsController.instance.userInstanceName,
            SettingsController.instance.accessToken),
        context,
        onOK: () => setState(() {}),
      );

  final TextEditingController addFilterTagController = TextEditingController();
  final TextEditingController addPreferenceController = TextEditingController();
  final TextEditingController addPreferenceValueController =
      TextEditingController();
  String tagAddType = "none";
  String addPreferenceMode = "preference";
  String addPreferenceSearch = "tags";

  void addTag(String type, String value) {
    if (value.isEmpty) {
      return;
    }

    FediMatchHelper.setFediMatchTags(Mastodon.instance.self.fediMatchTags
        .followedBy([FediMatchTag(type, value)]).toList());
    addFilterTagController.clear();
    Update();
  }

  void addFilter(String mode, String search, String preference, {int? value}) {
    if (preference.isEmpty) {
      Util.showErrorScaffold(context, "Preference can't be empty");
      return;
    }
    if (mode == "preference" && (value == null || value == 0)) {
      Util.showErrorScaffold(context, "Value can't be empty or 0");
      return;
    }

    SettingsController.instance
        .updateFilters(SettingsController.instance.filters.followedBy([
      FediMatchFilter(
        mode,
        search,
        preference,
        value: value,
      ),
    ]).toList());

    addPreferenceController.clear();
    addPreferenceValueController.clear();
    Update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar("Settings"),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: ScrollController(),
          children: [
            AccountView(Mastodon.instance.self, edgeInset: 0),
            SizedBox(height: 20),

            SizedBox(height: 20),
            Text(
              "General",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListTile(
              leading: Icon(Icons.color_lens,
                  color: Theme.of(context).colorScheme.primary),
              title: Text(
                'Color',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              trailing: DropdownButton<FlexScheme>(
                underline: Container(),
                value: SettingsController.instance.themeColor,
                onChanged: SettingsController.instance.updateThemeColor,
                selectedItemBuilder: (BuildContext context) {
                  return FlexScheme.values.map((FlexScheme scheme) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Text(scheme.name),
                    );
                  }).toList();
                },
                items: FlexScheme.values.map((FlexScheme scheme) {
                  return DropdownMenuItem(
                    alignment: Alignment.centerRight,
                    value: scheme,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(scheme.name),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GridView.count(
                            crossAxisCount: 2,
                            children: [
                              Container(
                                color: FlexColorScheme.light(scheme: scheme)
                                    .primary,
                              ),
                              Container(
                                color: FlexColorScheme.light(scheme: scheme)
                                    .secondary,
                              ),
                              Container(
                                color: FlexColorScheme.dark(scheme: scheme)
                                    .primary,
                              ),
                              Container(
                                color: FlexColorScheme.dark(scheme: scheme)
                                    .secondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            // Theme
            ListTile(
              leading: switch (SettingsController.instance.themeMode) {
                ThemeMode.system => Icon(Icons.brightness_4,
                    color: Theme.of(context).colorScheme.primary),
                ThemeMode.light => Icon(Icons.brightness_5,
                    color: Theme.of(context).colorScheme.primary),
                ThemeMode.dark => Icon(Icons.brightness_3,
                    color: Theme.of(context).colorScheme.primary),
              },
              title: Text(
                'Theme',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              trailing: DropdownButton<ThemeMode>(
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
            ),

            // Chat mention safety
            ListTile(
              leading: Icon(Icons.shield,
                  color: SettingsController.instance.chatMentionSafety
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface),
              title: Text(
                'Chat mention safety',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              trailing: Switch(
                value: SettingsController.instance.chatMentionSafety,
                onChanged: (bool value) {
                  if (value) {
                    Util.popUpDialog(
                        context,
                        "Chat mention safety",
                        "Chat mention safety will prevent you from mentioning people in chat."
                            "\nIt will remove all '@' characters from your messages."
                            "\n\nDo you want to enable chat mention safety?",
                        "Acknowledge", () {
                      SettingsController.instance
                          .updateChatMentionSafety(value);
                      Update();
                    });
                  }
                  SettingsController.instance.updateChatMentionSafety(value);
                },
              ),
            ),

            SizedBox(height: 20),
            Text("Opt-in", style: Theme.of(context).textTheme.titleMedium),
            // Opt-in
            ListTile(
              leading: Icon(Icons.handshake,
                  color: Mastodon.instance.self.hasFediMatchField
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface),
              title: Text(
                'Opt-in to FediMatch',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              trailing: Switch(
                value: Mastodon.instance.self.hasFediMatchField,
                onChanged: (bool value) {
                  if (value) {
                    Util.executeWhenOK(
                      FediMatchHelper.optInToFediMatch(),
                      context,
                      onOK: Update,
                    );
                  } else {
                    Util.executeWhenOK(
                      FediMatchHelper.optOutOfFediMatch(),
                      context,
                      onOK: Update,
                    );
                  }
                },
              ),
            ),

            // Opt-in Matching
            Mastodon.instance.self.hasFediMatchField
                ? ListTile(
                    leading: Icon(Icons.hotel_class,
                        color: Mastodon.instance.self.hasFediMatchKeyField
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface),
                    title: Text(
                      'FediMatch Matching',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    trailing: Switch(
                      value: Mastodon.instance.self.hasFediMatchKeyField,
                      onChanged: (bool value) {
                        if (value) {
                          Util.popUpDialog(
                              context,
                              "FediMatch Matching",
                              "FediMatch Matching will post your likes and superlikes as encrypted unlisted toots."
                                  "\nThis will allow other FediMatch users (only the ones affected by each like or superlike) to make a match with you."
                                  "\n\nDo you want to opt-in to FediMatch Matching?",
                              "Acknowledge", () {
                            Util.askForPassword(
                              context,
                              (password) => Util.executeWhenOK(
                                FediMatchHelper.optInToFediMatchMatching(
                                    password),
                                context,
                                onOK: Update,
                              ),
                            );
                          });
                        } else {
                          Util.executeWhenOK(
                            FediMatchHelper.optOutOfFediMatchMatching(),
                            context,
                            onOK: Update,
                          );
                        }
                      },
                    ),
                  )
                : Container(),
            SizedBox(height: 20),
            Text("Filtering", style: Theme.of(context).textTheme.titleMedium),

            // Filters
            // Show non-opt-in accounts
            ListTile(
              leading: Icon(Icons.warning_rounded,
                  color: SettingsController.instance.showNonOptInAccounts
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface),
              title: Text(
                'Show non-opt-in accounts',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              trailing: Switch(
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
                  SettingsController.instance.updateShowNonOptInAccounts(value);
                  Update();
                },
              ),
            ),

            // Filter tags
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  boxShadow: Util.boxShadow(context)),
              child: Column(
                children: [
                  DismissableList(
                    "Your tags",
                    Mastodon.instance.self.fediMatchTags.map(
                      (e) {
                        return ListTile(
                          tileColor: FediMatchTag.getColor(
                              Theme.of(context), e.tagType),
                          title: Text(e.tagValue),
                        );
                      },
                    ).toList(),
                    icon: Icons.tag,
                    initiallyExpanded: true,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    onStateChanged: () {
                      setState(() {});
                    },
                    onDismissed: (index) {
                      Util.executeWhenOK(
                        FediMatchHelper.setFediMatchTags(Mastodon
                            .instance.self.fediMatchTags
                            .where((e) =>
                                e.tagValue !=
                                Mastodon.instance.self.fediMatchTags[index]
                                    .tagValue)
                            .toList()),
                        context,
                        onOK: Update,
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color:
                          FediMatchTag.getColor(Theme.of(context), tagAddType),
                    ),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        DropdownButton<String>(
                          underline: Container(),
                          value: tagAddType,
                          onChanged: (value) {
                            setState(() {
                              tagAddType = value!;
                            });
                          },
                          items: FediMatchTag.colors(Theme.of(context))
                              .keys
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: addFilterTagController,
                                decoration: InputDecoration(
                                  labelText: "Add tag",
                                  border: InputBorder.none,
                                ),
                                onFieldSubmitted: (value) {
                                  addTag(tagAddType, value);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                addTag(tagAddType, addFilterTagController.text);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  boxShadow: Util.boxShadow(context)),
              child: Column(
                children: [
                  DismissableList(
                    "Your \"Algorithm\"",
                    SettingsController.instance.filters.map(
                      (e) {
                        return ListTile(
                          tileColor:
                              FediMatchFilter.color(e.mode, Theme.of(context)),
                          title: Text(e.preference),
                          subtitle: Text("in " + e.search),
                          trailing: e.value == null
                              ? null
                              : Text(
                                  e.value.toString(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                        );
                      },
                    ).toList(),
                    icon: Icons.lightbulb,
                    initiallyExpanded: true,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    onStateChanged: () {
                      setState(() {});
                    },
                    onDismissed: (index) {
                      SettingsController.instance.updateFilters(
                        SettingsController.instance.filters
                            .where((e) =>
                                e.id !=
                                SettingsController.instance.filters[index].id)
                            .toList(),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: FediMatchFilter.color(
                            addPreferenceMode, Theme.of(context))),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        ...(addPreferenceMode == "preference"
                            ? [
                                Text("For"),
                                SizedBox(width: 10),
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: TextFormField(
                                    controller: addPreferenceValueController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]'),
                                      ),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onFieldSubmitted: (value) {
                                      addTag(tagAddType, value);
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                              ]
                            : []),
                        DropdownButton<String>(
                          underline: Container(),
                          value: addPreferenceSearch,
                          onChanged: (value) {
                            setState(() {
                              addPreferenceSearch = value!;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: "tags",
                              child: Text("Tags"),
                            ),
                            DropdownMenuItem(
                              value: "note",
                              child: Text("Note"),
                            ),
                          ],
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          underline: Container(),
                          value: addPreferenceMode,
                          onChanged: (value) {
                            setState(() {
                              addPreferenceMode = value!;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: "must",
                              child: Text("must"),
                            ),
                            DropdownMenuItem(
                              value: "preference",
                              child: Text("should"),
                            ),
                            DropdownMenuItem(
                              value: "cant",
                              child: Text("can't"),
                            ),
                          ],
                        ),
                        Text("cotain"),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: addPreferenceController,
                                decoration: InputDecoration(
                                  labelText: "Add preference",
                                  border: InputBorder.none,
                                ),
                                onFieldSubmitted: (text) {
                                  addFilter(
                                    addPreferenceMode,
                                    addPreferenceSearch,
                                    text,
                                    value: int.tryParse(
                                        addPreferenceValueController.text),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                addFilter(
                                  addPreferenceMode,
                                  addPreferenceSearch,
                                  addPreferenceController.text,
                                  value: int.tryParse(
                                      addPreferenceValueController.text),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            Text("Danger zone", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            // Clear Matcher data
            TextButton(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clear Matcher data',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ],
                ),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Util.popUpDialog(
                  context,
                  "Delete Matcher Data",
                  "Are you sure you want to delete all Matcher data?"
                      "\nYou will loose ${Matcher.liked.length} liked accounts, ${Matcher.disliked.length} disliked accounts and ${Matcher.superliked.length} superliked accounts, as well as ${Matcher.matches.length} matches.",
                  "Delete",
                  () {
                    Matcher.clear();
                    Update();
                  },
                );
              },
            ),
            SizedBox(height: 10),

            // Logout
            TextButton(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ],
                ),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Util.popUpDialog(
                  context,
                  "Logout",
                  "Are you sure you want to log out?"
                      "\nYou will loose ${Matcher.liked.length} liked accounts, ${Matcher.disliked.length} disliked accounts and ${Matcher.superliked.length} superliked accounts, as well as ${Matcher.matches.length} matches.",
                  "Logout",
                  () async {
                    Matcher.clear();

                    await Mastodon.Logout();
                    await Matcher.deleteKeyValuePair();
                    Matcher.uploaded = [];
                    SettingsController.instance.updateUserInstanceName("");
                    SettingsController.instance.updateAccessToken("");

                    Navigator.pushReplacementNamed(
                        context, LoginView.routeName);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
