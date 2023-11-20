import 'package:flutter/material.dart';

class LabeledIcon extends StatelessWidget {
  const LabeledIcon(
      {super.key,
      required this.iconData,
      required this.label,
      required this.onTap});

  final IconData iconData;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        radius: 32,
        child: Center(
          child: Ink(
            width: 108,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(iconData, size: 24),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
