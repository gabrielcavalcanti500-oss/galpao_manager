import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback? onCompraFinalizada;
  final VoidCallback? onVendaFinalizada;
  final VoidCallback? onGastoFinalizado;

  const QuickActions({
    super.key,
    this.onCompraFinalizada,
    this.onVendaFinalizada,
    this.onGastoFinalizado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acesso rápido',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172B4D),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'O que você deseja registrar?',
          style: TextStyle(fontSize: 12, color: Color(0xFF758195)),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _QuickButton(
                icon: Icons.add_shopping_cart_rounded,
                label: 'Compra',
                color: const Color(0xFF16804A),
                onTap: () async {
                  await context.push('/compras');
                  onCompraFinalizada?.call();
                },
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickButton(
                icon: Icons.point_of_sale_rounded,
                label: 'Venda',
                color: const Color(0xFF2864C5),
                onTap: () async {
                  await context.push('/vendas');
                  onVendaFinalizada?.call();
                },
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: _QuickButton(
                icon: Icons.receipt_long_rounded,
                label: 'Gasto',
                color: const Color(0xFFD97706),
                onTap: () async {
                  await context.push('/gastos');
                  onGastoFinalizado?.call();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE8EDF3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF24364B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
