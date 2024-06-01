import 'dart:math';

import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match_list_section.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/elements/nav_bar.dart';
import 'package:fedi_match/src/views/account_chat_view.dart';
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
      bottomNavigationBar: NavBar("Likes & Matches"),
      appBar: AppBar(
        title: const Text('Likes & Matches'),
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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        Container(
                          width: constraints.maxWidth - 100,
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
                    // Upload Likes
                    Mastodon.instance.self.hasFediMatchKeyField() &&
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                              "Upload Likes (${Matcher.numToUpload()})",
                            ),
                          )
                        : Container(),
                    SizedBox(height: 20),
                    MatchListSection(
                      "Matches",
                      Matcher.matches,
                      color: Colors.orange,
                      icon: Icons.hotel_class,
                      emptyMessage: "no matches yet",
                      initiallyExpanded: true,
                      onDismissed: (url) => Matcher.removeMatch(url),
                    ),
                    MatchListSection(
                      "Superliked",
                      Matcher.superliked,
                      color: Colors.blue,
                      icon: Icons.star,
                      emptyMessage: "no superlikes yet",
                      onDismissed: (url) => Matcher.removeSuperlike(url),
                    ),
                    MatchListSection(
                      "Liked",
                      Matcher.liked,
                      color: Colors.green,
                      icon: Icons.favorite,
                      emptyMessage: "no likes yet",
                      onDismissed: (url) => Matcher.removeLike(url),
                    ),
                  ],
                ),
              ),
              MatchedAnimation(),
            ],
          );
        },
      ),
    );
  }
}

class MatchedAnimation extends StatefulWidget {
  @override
  State<MatchedAnimation> createState() => _MatchedAnimationState();
}

class _MatchedAnimationState extends State<MatchedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(Matcher.newMatches.length);
    if (Matcher.newMatches.length > 0) {
      controller.forward();
    } else {
      return Container();
    }

    Account account = Matcher.newMatches.first;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Positioned(
          top: 0,
          left: 0,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: AnimatedBuilder(
            animation: animation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New Match!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircleAvatar(
                    backgroundImage: NetworkImage(account.avatar),
                    radius: constraints.maxWidth / 4,
                  ),
                  SizedBox(height: 20),
                  Text(
                    account.getDisplayName() == ""
                        ? account.username
                        : account.getDisplayName(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: new ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.secondary)),
                        onPressed: () {
                          setState(() {
                            Matcher.newMatches.remove(account);
                            controller.reset();
                          });
                        },
                        child: Text("Dismiss",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary)),
                      ),
                      ElevatedButton(
                        style: new ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary)),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AccountChatView.routeName,
                            arguments: {
                              "account": account,
                            },
                          );
                          setState(() {
                            Matcher.newMatches.remove(account);
                            controller.reset();
                          });
                        },
                        child: Text(
                          "Chat",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return Container(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  color: Colors.black.withOpacity(min(
                      Curves.elasticOut.transform(animation.value) * 0.75, 1)),
                  child: Transform.scale(
                    scale: Curves.elasticOut.transform(animation.value),
                    child: child,
                  ));
            },
          ),
        );
      },
    );
  }
}
