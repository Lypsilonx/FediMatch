import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/match_buttons.dart';
import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {
  final AppinioSwiperController controller;
  final Account account;

  const SwipeCard(this.controller, this.account);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Card(
          clipBehavior: Clip.hardEdge,
          color: Theme.of(context).colorScheme.surfaceContainer,
          shadowColor: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(children: [
                Image(
                    image: NetworkImage(account.avatar),
                    fit: BoxFit.cover,
                    width: 400,
                    height: 400),
                Container(
                  width: 400,
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.getDisplayName(),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 24)),
                            Text("@" + account.acct,
                                overflow: TextOverflow.ellipsis),
                          ])),
                )
              ]),
              MatchButtons(controller: controller),
            ],
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/account',
              arguments: {"account": account, "controller": controller});
        });
  }
}
