import '../../../../core/database/app_database.dart';
import '../../../compras/data/materials_data.dart';
import '../../../compras/domain/entities/material_model.dart';

class EstoqueRepository {
  final AppDatabase _database;

  EstoqueRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  Future<double> calcularQuantidadeComprada(MaterialModel material) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(quantidade), 0) AS total
      FROM itens_compra
      WHERE material_nome = ?
      ''',
      [material.nome],
    );

    return (resultado.first['total'] as num).toDouble();
  }

  Future<double> calcularQuantidadeVendida(MaterialModel material) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(quantidade), 0) AS total
      FROM itens_venda
      WHERE material_nome = ?
      ''',
      [material.nome],
    );

    return (resultado.first['total'] as num).toDouble();
  }

  Future<double> calcularEstoque(MaterialModel material) async {
    final comprado = await calcularQuantidadeComprada(material);
    final vendido = await calcularQuantidadeVendida(material);

    return comprado - vendido;
  }

  Future<List<MaterialModel>> buscarMateriais() async {
    return materiais;
  }
}
