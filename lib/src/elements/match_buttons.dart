import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/mastodon.dart';
import 'package:fedi_match/src/elements/action_button.dart';
import 'package:fedi_match/src/settings/settings_controller.dart';
import 'package:fedi_match/util.dart';
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
    String followStatus = Mastodon.selfFollowing.contains(widget.account.url)
        ? "Following"
        : Mastodon.selfRequested.contains(widget.account.url)
            ? "Requested"
            : "Follow";
    return Padding(
      padding: EdgeInsets.all(20),
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ActionButton(
              Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onError,
              ),
              Theme.of(context).colorScheme.error, () {
            widget.controller.swipeLeft();
            if (widget.postSwipe != null) {
              widget.postSwipe!();
            }
          }),
          ActionButton(
              Icon(
                  switch (followStatus) {
                    "Following" => Icons.person_remove,
                    "Requested" => Icons.hourglass_empty,
                    "Follow" => Icons.person_add,
                    _ => Icons.question_mark,
                  },
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]
                      : Colors.white),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blueAccent
                  : Colors.blue, () {
            if (followStatus != "Follow") {
              Util.executeWhenOK(
                Mastodon.unfollow(
                    widget.account, SettingsController.instance.accessToken),
                context,
                onOK: () {
                  setState(() {});
                },
              );
            } else {
              Util.executeWhenOK(
                Mastodon.follow(
                    widget.account, SettingsController.instance.accessToken),
                context,
                onOK: () {
                  setState(() {});
                },
              );
            }
            if (widget.postSwipe != null) {
              widget.postSwipe!();
            }
          }),
          ActionButton(
              Icon(Icons.favorite,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.green[900]
                      : Colors.white),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.green
                  : Colors.green, () {
            widget.controller.swipeRight();
            if (widget.postSwipe != null) {
              widget.postSwipe!();
            }
          }),
        ],
      ),
    );
  }
}
