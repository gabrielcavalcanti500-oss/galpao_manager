import 'item_compra.dart';

class Compra {
  final int? id;
  final DateTime data;
  final List<ItemCompra> itens;

  const Compra({this.id, required this.data, required this.itens});

  double get total {
    return itens.fold(0, (total, item) => total + item.subtotal);
  }

  double get pesoTotal {
    return itens
        .where((item) => item.vendidoPorPeso)
        .fold(0, (total, item) => total + item.quantidade);
  }

  int get quantidadeItens => itens.length;
}
