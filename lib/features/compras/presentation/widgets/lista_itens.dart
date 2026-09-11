import 'package:flutter/material.dart';

import '../../domain/entities/item_compra.dart';
import 'item_compra_card.dart';

class ListaItens extends StatelessWidget {
  final List<ItemCompra> itens;
  final ValueChanged<int>? onEdit;
  final ValueChanged<int>? onDelete;

  const ListaItens({
    super.key,
    required this.itens,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(Icons.shopping_basket_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhum material adicionado',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Adicione um material para iniciar a compra.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(itens.length, (index) {
        final item = itens[index];

        return ItemCompraCard(
          item: item,
          onEdit: onEdit == null ? null : () => onEdit!(index),
          onDelete: onDelete == null ? null : () => onDelete!(index),
        );
      }),
    );
  }
}
