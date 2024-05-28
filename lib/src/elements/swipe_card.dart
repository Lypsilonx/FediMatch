import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/action_button.dart';
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
          color: Colors.white,
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
                            Text(account.displayName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 24)),
                            Text("@" + account.acct,
                                overflow: TextOverflow.ellipsis),
                          ])),
                )
              ]),
              Padding(
                padding: EdgeInsets.all(20),
                child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ActionButton(Icon(Icons.close, color: Colors.white),
                        Colors.red, controller.swipeLeft),
                    ActionButton(Icon(Icons.star, color: Colors.white),
                        Colors.blue, controller.swipeUp),
                    ActionButton(Icon(Icons.favorite, color: Colors.white),
                        Colors.green, controller.swipeRight),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/account',
              arguments: {"account": account, "controller": controller});
        });
  }
}
