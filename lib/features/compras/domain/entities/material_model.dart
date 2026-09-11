import 'tipo_material.dart';

class MaterialModel {
  final String nome;
  final TipoMaterial tipo;
  final double? precoPadrao;

  const MaterialModel({
    required this.nome,
    required this.tipo,
    this.precoPadrao,
  });

  bool get vendidoPorPeso => tipo == TipoMaterial.peso;

  bool get vendidoPorUnidade => tipo == TipoMaterial.unidade;
}
