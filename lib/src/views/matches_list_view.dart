import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match_list_section.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:flutter/material.dart';

class MatchesListView extends StatefulWidget {
  MatchesListView({super.key});

  static const routeName = '/matches';

  @override
  State<MatchesListView> createState() => _MatchesListViewState();
}

class _MatchesListViewState extends State<MatchesListView> {
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
        Matcher.addToLiked(account);
        searchController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'User not found',
          style: new TextStyle(
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        showCloseIcon: true,
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavBar("Likes & Matches"),
        appBar: AppBar(
          title: const Text('Likes & Matches'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(controller: ScrollController(), children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Container(
                  width: 300,
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
            MatchListSection(
              "Matches",
              Matcher.matches,
              color: Colors.orange,
              icon: Icons.hotel_class,
              emptyMessage: "no matches yet (WIP)",
              initiallyExpanded: true,
            ),
            MatchListSection("Superliked", Matcher.superliked,
                color: Colors.blue,
                icon: Icons.star,
                emptyMessage: "no superlikes yet"),
            MatchListSection("Liked", Matcher.liked,
                color: Colors.green,
                icon: Icons.favorite,
                emptyMessage: "no likes yet"),
          ]),
        ));
  }
}
