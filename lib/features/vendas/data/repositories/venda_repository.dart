import '../../../../core/database/app_database.dart';
import '../../../compras/data/materials_data.dart';
import '../../../compras/domain/entities/material_model.dart';
import '../../domain/entities/item_venda.dart';
import '../../domain/entities/venda.dart';

class VendaRepository {
  final AppDatabase _database;

  VendaRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  Future<int> salvarVenda(Venda venda) async {
    final db = await _database.database;

    return db.transaction<int>((txn) async {
      final vendaId = await txn.insert('vendas', {
        'data': venda.data.toIso8601String(),
        'total': venda.total,
      });

      for (final item in venda.itens) {
        await txn.insert('itens_venda', {
          'venda_id': vendaId,
          'material_nome': item.material.nome,
          'tipo_material': item.material.tipo.name,
          'quantidade': item.quantidade,
          'preco_unitario': item.precoUnitario,
          'subtotal': item.subtotal,
        });
      }

      return vendaId;
    });
  }

  Future<List<Venda>> buscarVendas() async {
    final db = await _database.database;

    final vendasData = await db.query('vendas', orderBy: 'data DESC');

    final List<Venda> vendas = [];

    for (final vendaData in vendasData) {
      final vendaId = vendaData['id'] as int;

      final itensData = await db.query(
        'itens_venda',
        where: 'venda_id = ?',
        whereArgs: [vendaId],
      );

      final List<ItemVenda> itens = [];

      for (final itemData in itensData) {
        final nomeMaterial = itemData['material_nome'] as String;

        final material = _encontrarMaterial(nomeMaterial);

        if (material == null) {
          continue;
        }

        itens.add(
          ItemVenda(
            material: material,
            quantidade: (itemData['quantidade'] as num).toDouble(),
            precoUnitario: (itemData['preco_unitario'] as num).toDouble(),
          ),
        );
      }

      vendas.add(
        Venda(
          id: vendaId,
          data: DateTime.parse(vendaData['data'] as String),
          itens: itens,
        ),
      );
    }

    return vendas;
  }

  MaterialModel? _encontrarMaterial(String nome) {
    for (final material in materiais) {
      if (material.nome == nome) {
        return material;
      }
    }

    return null;
  }

  Future<void> excluirVenda(int vendaId) async {
    final db = await _database.database;

    await db.delete('itens_venda', where: 'venda_id = ?', whereArgs: [vendaId]);

    await db.delete('vendas', where: 'id = ?', whereArgs: [vendaId]);
  }

  Future<double> calcularValorTotalVendido() async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS total FROM vendas',
    );

    return (resultado.first['total'] as num).toDouble();
  }

  Future<double> calcularPesoTotalVendido() async {
    final db = await _database.database;

    final resultado = await db.rawQuery('''
      SELECT COALESCE(SUM(quantidade), 0) AS total
      FROM itens_venda
      WHERE tipo_material = 'peso'
    ''');

    return (resultado.first['total'] as num).toDouble();
  }
}
