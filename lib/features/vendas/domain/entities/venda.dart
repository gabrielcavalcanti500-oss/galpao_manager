import 'item_venda.dart';

class Venda {
  final int? id;
  final DateTime data;
  final List<ItemVenda> itens;

  const Venda({this.id, required this.data, required this.itens});

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
