import 'package:flutter/material.dart';

class FediMatchLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(right: 2),
          padding: EdgeInsets.only(right: 3, left: 3, top: 1, bottom: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Text('Fedi',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
        Text('Match',
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }
}
