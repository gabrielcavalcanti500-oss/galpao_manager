import '../domain/entities/material_model.dart';
import '../domain/entities/tipo_material.dart';

const materiais = [
  MaterialModel(nome: 'Ferro', tipo: TipoMaterial.peso, precoPadrao: 0.40),
  MaterialModel(nome: 'Lata', tipo: TipoMaterial.peso, precoPadrao: 6),
  MaterialModel(nome: 'Perfil', tipo: TipoMaterial.peso, precoPadrao: 6),
  MaterialModel(nome: 'Cobre', tipo: TipoMaterial.peso, precoPadrao: 35),
  MaterialModel(nome: 'Panela', tipo: TipoMaterial.peso, precoPadrao: 6),
  MaterialModel(nome: 'Chapa', tipo: TipoMaterial.peso, precoPadrao: 3),
  MaterialModel(nome: 'Inox', tipo: TipoMaterial.peso, precoPadrao: 2),
  MaterialModel(nome: 'Metal', tipo: TipoMaterial.peso, precoPadrao: 15),
  MaterialModel(nome: 'Rabicho', tipo: TipoMaterial.peso, precoPadrao: 6),
  MaterialModel(nome: 'Motor', tipo: TipoMaterial.unidade),
  MaterialModel(nome: 'Tubinho', tipo: TipoMaterial.peso, precoPadrao: 2.5),
  MaterialModel(nome: 'Antimonio', tipo: TipoMaterial.peso, precoPadrao: 3),
  MaterialModel(nome: 'Bateria', tipo: TipoMaterial.peso, precoPadrao: 2),
  MaterialModel(nome: 'Cavaco', tipo: TipoMaterial.peso, precoPadrao: 1),
  MaterialModel(
    nome: 'Placa Marrom',
    tipo: TipoMaterial.peso,
    precoPadrao: 0.6,
  ),
  MaterialModel(nome: 'Geladeira', tipo: TipoMaterial.peso, precoPadrao: 0.15),
  MaterialModel(
    nome: 'Ar condicionado',
    tipo: TipoMaterial.peso,
    precoPadrao: 40,
  ),
  MaterialModel(nome: 'Placa Azul', tipo: TipoMaterial.peso, precoPadrao: 7),
  MaterialModel(nome: 'Bloco', tipo: TipoMaterial.peso, precoPadrao: 3),
  MaterialModel(nome: 'Placa Verde', tipo: TipoMaterial.peso, precoPadrao: 2),
];
