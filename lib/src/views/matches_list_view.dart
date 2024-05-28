import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:flutter/material.dart';

class MatchesListView extends StatelessWidget {
  const MatchesListView({super.key});

  static const routeName = '/matches';

  List<Widget> renderAsMatches(List<String> urls, String emptyMessage) {
    return urls.length == 0
        ? [
            ListTile(
              title: Text(emptyMessage),
            )
          ]
        : urls.map((e) {
            String username = e.split("/").last;
            username = username.replaceFirst("@", "");
            String instance = e.replaceFirst("https://", "");
            instance = instance.split("/").first;
            Future<Account> account = Mastodon.getAccount(instance, username);
            return FutureBuilder<Account>(
              future: account,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ListTile(
                    leading: Icon(Icons.error),
                    title:
                        Text("Error loading account: $e (${snapshot.error})"),
                  );
                }

                if (snapshot.hasData) {
                  return Match(snapshot.data!);
                } else {
                  return ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text("Loading... ($e)"),
                  );
                }
              },
            );
          }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(
        MatchListHeader("Superliked", color: Colors.blue, icon: Icons.star));
    children.addAll(renderAsMatches(Matcher.superliked, "no superlikes yet"));
    children.add(SizedBox(height: 40));
    children.add(
        MatchListHeader("Liked", color: Colors.green, icon: Icons.favorite));
    children.addAll(renderAsMatches(Matcher.liked, "no likes yet"));
    return Scaffold(
        bottomNavigationBar: NavBar("Matches"),
        appBar: AppBar(
          title: const Text('Matches'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(controller: ScrollController(), children: children),
        ));
  }
}

class MatchListHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;

  const MatchListHeader(this.title,
      {super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(title, style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
