import 'dart:math';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/matcher.dart';
import 'package:fedi_match/src/views/account_chat_view.dart';
import 'package:flutter/material.dart';

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
