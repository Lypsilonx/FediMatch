import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/matched_animation.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';

class ChatsListView extends StatefulWidget {
  ChatsListView({super.key});

  static const routeName = '/chats';

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  TextEditingController searchController = TextEditingController();

  void search(String search) async {
    if (search.characters.first == '@') {
      search = search.substring(1);
    }

    if (!(search.characters.where((char) => char == '@').length == 1)) {
      return;
    }

    var instanceName = search.split('@')[1];
    var username = search.split('@')[0];

    try {
      var account = await Mastodon.getAccount(instanceName, username);

      setState(() {
        Matcher.addToChats(account);
        searchController.clear();
      });
    } catch (e) {
      Util.showErrorScaffold(context, "User not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(ChatsListView.routeName),
      appBar: AppBar(
        title: Text(
          'Chats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: ScrollController(),
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: searchController,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          helperText: 'search for a user',
                        ),
                        onFieldSubmitted: (String value) async {
                          search(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        search(searchController.text);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ...Matcher.chats.map((url) {
                  var instanceUsername =
                      FediMatchHelper.instanceUsernameFromUrl(url);
                  var instance = instanceUsername.$1;
                  var username = instanceUsername.$2;
                  Future<Account> account =
                      Mastodon.getAccount(instance, username);
                  return FutureBuilder<Account>(
                      future: account,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return ListTile(
                            leading: Icon(Icons.error),
                            title: Text(
                                "Error loading account: $url (${snapshot.error})"),
                          );
                        }

                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 40),
                            child: AccountView(snapshot.data!,
                                goto: "chat", edgeInset: 0),
                          );
                        } else {
                          return ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text("Loading... ($url)"),
                          );
                        }
                      });
                }).toList(),
              ],
            ),
          ),
          MatchedAnimation(),
        ],
      ),
    );
  }
}
