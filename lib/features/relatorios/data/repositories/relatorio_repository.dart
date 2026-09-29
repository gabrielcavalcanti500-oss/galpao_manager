import '../../../../core/database/app_database.dart';
import '../../domain/entities/item_relatorio.dart';
import '../../domain/entities/relatorio_compras.dart';

class RelatorioRepository {
  final AppDatabase _database;

  RelatorioRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  Future<List<Map<String, dynamic>>> buscarComprasPorPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT
        ic.material_nome,
        ic.tipo_material,
        SUM(ic.quantidade) AS quantidade,
        SUM(ic.subtotal) AS total
      FROM itens_compra ic
      INNER JOIN compras c
        ON c.id = ic.compra_id
      WHERE c.data >= ?
        AND c.data < ?
      GROUP BY ic.material_nome, ic.tipo_material
      ORDER BY ic.material_nome ASC
      ''',
      [inicio.toIso8601String(), fim.toIso8601String()],
    );

    return resultado;
  }

  Future<double> buscarTotalCompras({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total), 0) AS total
      FROM compras
      WHERE data >= ?
        AND data < ?
      ''',
      [inicio.toIso8601String(), fim.toIso8601String()],
    );

    return (resultado.first['total'] as num).toDouble();
  }

  Future<RelatorioCompras> gerarRelatorioCompras({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final resultado = await buscarComprasPorPeriodo(inicio: inicio, fim: fim);

    final itens = resultado.map((item) {
      return ItemRelatorio(
        materialNome: item['material_nome'] as String,
        tipoMaterial: item['tipo_material'] as String,
        quantidade: (item['quantidade'] as num).toDouble(),
        total: (item['total'] as num).toDouble(),
      );
    }).toList();

    final totalCompras = await buscarTotalCompras(inicio: inicio, fim: fim);

    return RelatorioCompras(
      inicio: inicio,
      fim: fim,
      itens: itens,
      totalCompras: totalCompras,
    );
  }
}
