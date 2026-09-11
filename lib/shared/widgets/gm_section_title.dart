import 'package:flutter/material.dart';

class GMSectionTitle extends StatelessWidget {
  final String titulo;

  const GMSectionTitle({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
