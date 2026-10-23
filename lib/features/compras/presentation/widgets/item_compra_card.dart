import 'package:flutter/material.dart';

import '../../domain/entities/item_compra.dart';

class ItemCompraCard extends StatelessWidget {
  final ItemCompra item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCompraCard({
    super.key,
    required this.item,
    this.onEdit,
    this.onDelete,
  });

  static const Color _navy = Color(0xFF172B4D);
  static const Color _green = Color(0xFF16865B);
  static const Color _greenLight = Color(0xFFE8F6EF);
  static const Color _muted = Color(0xFF718096);
  static const Color _border = Color(0xFFE8EDF3);

  String _moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final porUnidade = item.vendidoPorUnidade;

    final quantidade = porUnidade
        ? '${item.quantidade.toStringAsFixed(0)} un'
        : '${item.quantidade.toStringAsFixed(2).replaceAll('.', ',')} kg';

    final preco = porUnidade
        ? '${_moeda(item.precoUnitario)}/un'
        : '${_moeda(item.precoUnitario)}/kg';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    porUnidade
                        ? Icons.inventory_2_rounded
                        : Icons.scale_rounded,
                    color: _green,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.material.nome,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$quantidade  •  $preco',
                        style: const TextStyle(color: _muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Subtotal do item',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _moeda(item.subtotal),
                    style: const TextStyle(
                      color: _green,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: _navy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD64545),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
