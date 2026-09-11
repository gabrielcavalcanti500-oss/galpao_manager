import 'material_model.dart';

class ItemCompra {
  final MaterialModel material;

  /// Peso (kg) ou quantidade, dependendo do tipo do material
  final double quantidade;

  /// Valor por kg ou por unidade
  final double precoUnitario;

  const ItemCompra({
    required this.material,
    required this.quantidade,
    required this.precoUnitario,
  });

  double get subtotal => quantidade * precoUnitario;

  bool get vendidoPorPeso => material.vendidoPorPeso;

  bool get vendidoPorUnidade => material.vendidoPorUnidade;
}
