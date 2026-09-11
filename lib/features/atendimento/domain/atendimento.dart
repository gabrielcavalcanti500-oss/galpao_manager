import 'item_atendimento.dart';

class Atendimento {
  final List<ItemAtendimento> itens;

  Atendimento({required this.itens});

  double get total {
    double valor = 0;

    for (final item in itens) {
      valor += item.subtotal;
    }

    return valor;
  }
}
