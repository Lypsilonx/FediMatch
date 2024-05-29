import 'package:fedi_match/src/elements/match_list_section.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:flutter/material.dart';

class MatchesListView extends StatelessWidget {
  const MatchesListView({super.key});

  static const routeName = '/matches';

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(MatchListSection(
      "Matches",
      Matcher.matches,
      color: Colors.orange,
      icon: Icons.hotel_class,
      emptyMessage: "no matches yet (WIP)",
      initiallyExpanded: true,
    ));
    children.add(MatchListSection("Superliked", Matcher.superliked,
        color: Colors.blue,
        icon: Icons.star,
        emptyMessage: "no superlikes yet"));
    children.add(MatchListSection("Liked", Matcher.liked,
        color: Colors.green,
        icon: Icons.favorite,
        emptyMessage: "no likes yet"));

    return Scaffold(
        bottomNavigationBar: NavBar("Likes & Matches"),
        appBar: AppBar(
          title: const Text('Likes & Matches'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(controller: ScrollController(), children: children),
        ));
  }
}
