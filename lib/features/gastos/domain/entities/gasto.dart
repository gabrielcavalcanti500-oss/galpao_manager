class Gasto {
  final int? id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String? observacao;

  const Gasto({
    this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    this.observacao,
  });
}
