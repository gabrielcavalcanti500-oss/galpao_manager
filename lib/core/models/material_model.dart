class MaterialModel {
  final String nome;
  final double precoKg;
  final bool porUnidade;

  const MaterialModel({
    required this.nome,
    required this.precoKg,
    this.porUnidade = false,
  });
}
