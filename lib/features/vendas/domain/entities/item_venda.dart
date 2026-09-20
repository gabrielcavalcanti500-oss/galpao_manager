import '../../../compras/domain/entities/material_model.dart';

class ItemVenda {
  final MaterialModel material;

  /// Peso (kg) ou quantidade, dependendo do tipo do material
  final double quantidade;

  /// Valor de venda por kg ou por unidade
  final double precoUnitario;

  const ItemVenda({
    required this.material,
    required this.quantidade,
    required this.precoUnitario,
  });

  double get subtotal => quantidade * precoUnitario;

  bool get vendidoPorPeso => material.vendidoPorPeso;
  bool get vendidoPorUnidade => material.vendidoPorUnidade;
}
