import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/match_buttons.dart';
import 'package:fedi_match/src/views/account_details_view.dart';
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
                    padding: EdgeInsets.only(
                        left: 20, right: 20, bottom: 20, top: 10),
                    child: Column(
                      children: [
                        AccountView(account, showIcon: false, edgeInset: 0),
                        SizedBox(height: 5),
                        Flex(
                            direction: Axis.horizontal,
                            children: AccountDetailsView.renderFediMatchTags(
                                context, account)),
                      ],
                    ),
                  ),
                ),
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
