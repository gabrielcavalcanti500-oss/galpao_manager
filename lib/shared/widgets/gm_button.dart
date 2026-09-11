import 'package:flutter/material.dart';

class GMButton extends StatelessWidget {
  final String texto;
  final IconData icone;
  final VoidCallback onPressed;
  final Color? color;

  const GMButton({
    super.key,
    required this.texto,
    required this.icone,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icone),
        label: Text(texto),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
