import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FediMatchLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.centerRight,
          width: 100,
          child: Text('Fedi',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        Stack(
          children: [
            SvgPicture.asset('assets/FediMatch_Logo_1.svg',
                semanticsLabel: 'Fedi Match Logo',
                width: 50,
                height: 50,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary, BlendMode.modulate)),
            SvgPicture.asset('assets/FediMatch_Logo_2.svg',
                semanticsLabel: 'Fedi Match Logo',
                width: 50,
                height: 50,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.inversePrimary,
                    BlendMode.modulate)),
          ],
        ),
        Container(
          alignment: Alignment.centerLeft,
          width: 100,
          child: Text('Match',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }
}
