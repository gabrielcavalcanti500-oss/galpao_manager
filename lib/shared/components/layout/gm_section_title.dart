import 'package:flutter/material.dart';

class GMSectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const GMSectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}
