import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match_list_section.dart';
import 'package:fedi_match/src/elements/matched_animation.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/util.dart';
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
      Util.showErrorScaffold(context, "User not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavBar(MatchesListView.routeName),
      appBar: AppBar(
        title: Text(
          'Matches & Likes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Util.executeWhenOK(
                Matcher.findMatches(),
                context,
                onOK: () {
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: ScrollController(),
              children: [
                // Upload Likes
                Mastodon.instance.self.hasFediMatchKeyField &&
                        Matcher.numToUpload() > 0
                    ? TextButton(
                        style: new ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary)),
                        onPressed: () {
                          Util.executeWhenOK(
                            Matcher.uploadLikes(),
                            context,
                            onOK: () {
                              setState(() {});
                            },
                          );
                        },
                        child: Text(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                          "Upload Likes (${Matcher.numToUpload()})",
                        ),
                      )
                    : Container(),
                SizedBox(height: 20),
                MatchListSection(
                  "Matches",
                  Matcher.matches,
                  goto: "chat",
                  color: Colors.orange,
                  icon: Icons.hotel_class,
                  emptyMessage: "no matches yet",
                  initiallyExpanded: true,
                  onMatchDismissed: (url) => Matcher.removeMatch(url),
                ),
                MatchListSection(
                  "Likes",
                  Matcher.liked,
                  color: Colors.green,
                  icon: Icons.favorite,
                  emptyMessage: "no likes yet",
                  onMatchDismissed: (url) => Matcher.removeLike(url),
                ),
              ],
            ),
          ),
          MatchedAnimation(),
        ],
      ),
    );
  }
}
