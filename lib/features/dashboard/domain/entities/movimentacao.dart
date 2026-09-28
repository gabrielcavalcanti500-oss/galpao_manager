enum TipoMovimentacao { compra, venda, gasto }

class Movimentacao {
  final TipoMovimentacao tipo;
  final DateTime data;
  final double valor;
  final String descricao;
  final String? detalhe;

  const Movimentacao({
    required this.tipo,
    required this.data,
    required this.valor,
    required this.descricao,
    this.detalhe,
  });
}
