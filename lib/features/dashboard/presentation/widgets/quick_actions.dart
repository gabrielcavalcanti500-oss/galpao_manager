import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onCompraFinalizada;
  final VoidCallback? onGastoFinalizado;

  const QuickActions({
    super.key,
    this.onCompraFinalizada,
    this.onGastoFinalizado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _QuickButton(
          icon: Icons.shopping_cart_rounded,
          label: 'Compra',
          onTap: () async {
            await context.push('/compras');

            onCompraFinalizada?.call();
          },
        ),

        _QuickButton(
          icon: Icons.sell_rounded,
          label: 'Venda',
          onTap: () => context.push('/vendas'),
        ),

        _QuickButton(
          icon: Icons.receipt_long_rounded,
          label: 'Gasto',
          onTap: () async {
            await context.push('/gastos');

            onGastoFinalizado?.call();
          },
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: .12),
              child: Icon(icon, color: AppColors.primary),
            ),

            const SizedBox(height: 8),

            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
