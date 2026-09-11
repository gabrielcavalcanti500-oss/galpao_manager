enum UnidadeMaterial { kg, unidade }

class MaterialModel {
  final int? id;
  final String nome;
  final double precoPadrao;
  final UnidadeMaterial unidade;
  final bool ativo;

  const MaterialModel({
    this.id,
    required this.nome,
    required this.precoPadrao,
    required this.unidade,
    this.ativo = true,
  });
}
