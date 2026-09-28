import 'item_relatorio.dart';

class RelatorioCompras {
  final DateTime inicio;
  final DateTime fim;
  final List<ItemRelatorio> itens;
  final double totalCompras;

  const RelatorioCompras({
    required this.inicio,
    required this.fim,
    required this.itens,
    required this.totalCompras,
  });
}
