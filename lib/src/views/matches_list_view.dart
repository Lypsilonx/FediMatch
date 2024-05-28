import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:flutter/material.dart';

class MatchesListView extends StatelessWidget {
  const MatchesListView({super.key});

  static const routeName = '/matches';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavBar("Matches"),
        appBar: AppBar(
          title: const Text('Matches'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: ScrollController(),
            children: Matcher.liked.map((e) {
              Future<Account> account =
                  Mastodon.getAccount("mastodon.social", e);
              return FutureBuilder<Account>(
                future: account,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Match(snapshot.data!);
                  } else {
                    return ListTile(
                      title: Text("Loading... ($e)"),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ));
  }
}
