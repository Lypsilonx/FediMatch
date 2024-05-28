import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Icon icon;
  final Color color;
  final Function() onPressed;

  ActionButton(this.icon, this.color, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Transform.scale(scale: 1.5, child: icon),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        backgroundColor: color,
        foregroundColor: color,
      ),
    );
  }
}
