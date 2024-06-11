import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/account_view.dart';
import 'package:fedi_match/src/elements/match_buttons.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/src/views/account_details_view.dart';
import 'package:fedi_match/util.dart';
import 'package:flutter/material.dart';

class SwipeCard extends StatelessWidget {
  final AppinioSwiperController controller;
  final Account account;

  const SwipeCard(this.controller, this.account);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GestureDetector(
          child: Card(
            elevation: 5,
            shadowColor: Theme.of(context).colorScheme.primary.withAlpha(50),
            clipBehavior: Clip.hardEdge,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Stack(
              children: [
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: decorationBackFromRating(
                    account
                        .rateWithFilters(SettingsController.instance.filters)
                        .$2,
                    context,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: [
                            Image(
                              image: NetworkImage(account.avatar),
                              fit: BoxFit.cover,
                              width: constraints.maxWidth - 10,
                              height: constraints.maxWidth - 10,
                              errorBuilder: Util.ImageErrorBuilder,
                            ),
                            Container(
                              width: constraints.maxWidth - 10,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 10),
                                child: Column(
                                  children: [
                                    AccountView(account,
                                        showIcon: false, edgeInset: 0),
                                    Container(
                                      width: constraints.maxWidth - 50,
                                      child: Wrap(
                                        direction: Axis.horizontal,
                                        spacing: 5,
                                        runSpacing: 5,
                                        alignment: WrapAlignment.start,
                                        children: AccountDetailsView
                                            .renderFediMatchTags(
                                                context, account),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        MatchButtons(controller: controller, account: account),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: percentViewFromRating(
                      account
                          .rateWithFilters(SettingsController.instance.filters)
                          .$2,
                      context,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.pushNamed(context, '/account',
                arguments: {"account": account, "controller": controller});
          });
    });
  }

  BoxDecoration decorationBackFromRating(double rating, BuildContext context) {
    if (SettingsController.instance.showRating == false) {
      return BoxDecoration();
    }

    if (rating < 0.3) {
      return BoxDecoration();
    } else if (rating <= 0.5) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 5,
        ),
      );
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.yellow[200]!,
            Colors.yellow[700]!,
            Colors.yellow[900]!,
          ],
        ),
      );
    }
  }

  Widget percentViewFromRating(double rating, BuildContext context) {
    if (SettingsController.instance.showRating == false) {
      return Container();
    }

    return Container(
      width: 90,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: switch (rating) {
          < 0.3 => Theme.of(context).colorScheme.surface,
          <= 0.5 => Theme.of(context).colorScheme.primary,
          _ => Colors.yellow[600],
        },
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Text(
          (account.rateWithFilters(SettingsController.instance.filters).$2 *
                      100)
                  .round()
                  .toString() +
              "%",
          style: TextStyle(
            color: switch (rating) {
              < 0.3 => Theme.of(context).colorScheme.onSurface,
              <= 0.5 => Theme.of(context).colorScheme.surfaceContainer,
              _ => Theme.of(context).colorScheme.error,
            },
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
