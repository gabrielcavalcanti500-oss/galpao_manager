class Retirada {
  final int? id;
  final String materialNome;
  final String tipoMaterial;
  final double quantidade;
  final DateTime data;

  const Retirada({
    this.id,
    required this.materialNome,
    required this.tipoMaterial,
    required this.quantidade,
    required this.data,
  });
}
