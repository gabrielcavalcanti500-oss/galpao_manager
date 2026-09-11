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

  @override
  Widget build(BuildContext context) {
    final bool porUnidade = item.vendidoPorUnidade;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffEAF7EF),
                  child: Icon(
                    porUnidade
                        ? Icons.inventory_2_rounded
                        : Icons.scale_rounded,
                    color: const Color(0xff0B7A3E),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.material.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        porUnidade
                            ? '${item.quantidade.toStringAsFixed(0)} un • '
                                  'R\$ ${item.precoUnitario.toStringAsFixed(2)}/un'
                            : '${item.quantidade.toStringAsFixed(2)} kg • '
                                  'R\$ ${item.precoUnitario.toStringAsFixed(2)}/kg',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Text('Subtotal', style: TextStyle(color: Colors.black54)),

                const Spacer(),

                Text(
                  'R\$ ${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0B7A3E),
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  label: const Text('Editar'),
                ),

                const SizedBox(width: 4),

                TextButton.icon(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
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
