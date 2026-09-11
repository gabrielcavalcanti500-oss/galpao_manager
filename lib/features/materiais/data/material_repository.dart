import '../domain/material.dart';

class MaterialRepository {
  final List<MaterialModel> materiais = [
    const MaterialModel(
      nome: 'Ferro',
      precoPadrao: 0.40,
      unidade: UnidadeMaterial.kg,
    ),

    const MaterialModel(
      nome: 'Lata',
      precoPadrao: 6,
      unidade: UnidadeMaterial.kg,
    ),

    const MaterialModel(
      nome: 'Perfil',
      precoPadrao: 6,
      unidade: UnidadeMaterial.kg,
    ),

    const MaterialModel(
      nome: 'Cobre',
      precoPadrao: 35,
      unidade: UnidadeMaterial.kg,
    ),

    const MaterialModel(
      nome: 'Motor',
      precoPadrao: 0,
      unidade: UnidadeMaterial.unidade,
    ),
  ];
}
