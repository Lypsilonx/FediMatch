import 'package:flutter/material.dart';

class DidNotOptInIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.error,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Did not",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onError, fontSize: 8),
          ),
          Icon(
            Icons.warning_rounded,
            color: Theme.of(context).colorScheme.onError,
            size: 16,
          ),
          Text(
            "Opt-in",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onError, fontSize: 8),
          ),
        ],
      ),
    );
  }
}
