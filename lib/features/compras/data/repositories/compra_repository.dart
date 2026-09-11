import '../../../../core/database/app_database.dart';
import '../materials_data.dart';
import '../../domain/entities/compra.dart';
import '../../domain/entities/item_compra.dart';
import '../../domain/entities/material_model.dart';

class CompraRepository {
  final AppDatabase _database;

  CompraRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  // =====================================================
  // SALVAR COMPRA
  // =====================================================

  Future<int> salvarCompra(Compra compra) async {
    final db = await _database.database;

    return db.transaction<int>((txn) async {
      final compraId = await txn.insert('compras', {
        'data': compra.data.toIso8601String(),
        'total': compra.total,
      });

      for (final item in compra.itens) {
        await txn.insert('itens_compra', {
          'compra_id': compraId,
          'material_nome': item.material.nome,
          'tipo_material': item.material.tipo.name,
          'quantidade': item.quantidade,
          'preco_unitario': item.precoUnitario,
          'subtotal': item.subtotal,
        });
      }

      return compraId;
    });
  }

  // =====================================================
  // BUSCAR COMPRAS
  // =====================================================

  Future<List<Compra>> buscarCompras() async {
    final db = await _database.database;

    final comprasData = await db.query('compras', orderBy: 'data DESC');

    final List<Compra> compras = [];

    for (final compraData in comprasData) {
      final compraId = compraData['id'] as int;

      final itensData = await db.query(
        'itens_compra',
        where: 'compra_id = ?',
        whereArgs: [compraId],
      );

      final List<ItemCompra> itens = [];

      for (final itemData in itensData) {
        final nomeMaterial = itemData['material_nome'] as String;

        final material = _encontrarMaterial(nomeMaterial);

        if (material == null) {
          continue;
        }

        itens.add(
          ItemCompra(
            material: material,
            quantidade: (itemData['quantidade'] as num).toDouble(),
            precoUnitario: (itemData['preco_unitario'] as num).toDouble(),
          ),
        );
      }

      compras.add(
        Compra(
          id: compraId,
          data: DateTime.parse(compraData['data'] as String),
          itens: itens,
        ),
      );
    }

    return compras;
  }

  // =====================================================
  // ENCONTRAR MATERIAL
  // =====================================================

  MaterialModel? _encontrarMaterial(String nome) {
    for (final material in materiais) {
      if (material.nome == nome) {
        return material;
      }
    }

    return null;
  }

  Future<double> calcularPesoTotalComprado() async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
    SELECT COALESCE(SUM(quantidade), 0) AS total
    FROM itens_compra
    WHERE tipo_material = ?
  ''',
      ['peso'],
    );

    final total = resultado.first['total'];

    return (total as num).toDouble();
  }

  Future<double> calcularValorTotalComprado() async {
    final db = await _database.database;

    final resultado = await db.rawQuery('''
    SELECT COALESCE(SUM(total), 0) AS total
    FROM compras
  ''');

    final total = resultado.first['total'];

    return (total as num).toDouble();
  }

  Future<void> excluirCompra(int compraId) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      // Remove os itens vinculados à compra
      await txn.delete(
        'itens_compra',
        where: 'compra_id = ?',
        whereArgs: [compraId],
      );

      // Remove a compra
      await txn.delete('compras', where: 'id = ?', whereArgs: [compraId]);
    });
  }
}
