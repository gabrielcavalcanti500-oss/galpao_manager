import 'item_relatorio.dart';

class RelatorioCompras {
  final DateTime inicio;
  final DateTime fim;

  // Compras
  final List<ItemRelatorio> itens;
  final double totalCompras;

  // Vendas
  final List<ItemRelatorio> itensVendidos;
  final double totalVendas;

  // Gastos
  final List<GastoRelatorio> gastos;
  final double totalGastos;

  const RelatorioCompras({
    required this.inicio,
    required this.fim,
    required this.itens,
    required this.totalCompras,
    required this.itensVendidos,
    required this.totalVendas,
    required this.gastos,
    required this.totalGastos,
  });

  double get resultado => totalVendas - totalCompras - totalGastos;
}

class GastoRelatorio {
  final String descricao;
  final double valor;
  final String? observacao;

  const GastoRelatorio({
    required this.descricao,
    required this.valor,
    this.observacao,
  });
}
