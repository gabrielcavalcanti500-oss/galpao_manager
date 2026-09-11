import 'package:flutter/material.dart';

class SubtotalCard extends StatelessWidget {
  final double subtotal;

  const SubtotalCard({super.key, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Subtotal", style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 6),

          Text(
            "R\$ ${subtotal.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
