import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fedi_match/src/elements/action_button.dart';
import 'package:flutter/material.dart';

class MatchButtons extends StatelessWidget {
  const MatchButtons({
    super.key,
    required this.controller,
    this.postSwipe = null,
  });

  final AppinioSwiperController controller;
  final Function? postSwipe;

  @override
  Widget build(BuildContext context) {
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
            controller.swipeLeft();
            if (postSwipe != null) {
              postSwipe!();
            }
          }),
          ActionButton(
              Icon(Icons.star,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]
                      : Colors.white),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.blueAccent
                  : Colors.blue, () {
            controller.swipeUp();
            if (postSwipe != null) {
              postSwipe!();
            }
          }),
          ActionButton(
              Icon(Icons.favorite,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.green[900]!
                      : Colors.white),
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.green[400]!
                  : Colors.green, () {
            controller.swipeRight();
            if (postSwipe != null) {
              postSwipe!();
            }
          }),
        ],
      ),
    );
  }
}
