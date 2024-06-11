import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/fedi_match_helper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/action_button.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:flutter/material.dart';

class MatchButtons extends StatefulWidget {
  const MatchButtons({
    super.key,
    required this.controller,
    required this.account,
    this.postSwipe = null,
  });

  final AppinioSwiperController controller;
  final Account account;
  final Function? postSwipe;

  @override
  State<MatchButtons> createState() => _MatchButtonsState();
}

class _MatchButtonsState extends State<MatchButtons> {
  @override
  Widget build(BuildContext context) {
    FediMatchAction dislikeAction = FediMatchAction.Dislike;
    FediMatchAction? primaryAction = SettingsController.instance.primaryAction;
    FediMatchAction? secondaryAction =
        SettingsController.instance.secondaryAction;

    return Padding(
      padding: EdgeInsets.all(20),
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ActionButton(
            Icon(
              dislikeAction.icon,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            dislikeAction.getColor(Theme.of(context)),
            () {
              widget.controller.swipeUp();
              if (widget.postSwipe != null) {
                widget.postSwipe!();
              }
            },
          ),
          secondaryAction != null
              ? ActionButton(
                  Icon(
                    secondaryAction.icon,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  secondaryAction.getColor(Theme.of(context)),
                  () {
                    widget.controller.swipeUp();
                    if (widget.postSwipe != null) {
                      widget.postSwipe!();
                    }
                  },
                )
              : ActionButton(
                  Icon(Icons.star, color: Colors.transparent),
                  Colors.transparent,
                  () {},
                ),
          primaryAction != null
              ? ActionButton(
                  Icon(
                    primaryAction.icon,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  primaryAction.getColor(Theme.of(context)),
                  () {
                    widget.controller.swipeRight();
                    if (widget.postSwipe != null) {
                      widget.postSwipe!();
                    }
                  },
                )
              : ActionButton(
                  Icon(Icons.star, color: Colors.transparent),
                  Colors.transparent,
                  () {},
                ),
        ],
      ),
    );
  }
}
