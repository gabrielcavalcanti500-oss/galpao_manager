import '../../../../core/database/app_database.dart';
import '../../domain/entities/item_relatorio.dart';
import '../../domain/entities/relatorio_compras.dart';

class RelatorioRepository {
  final AppDatabase _database;

  RelatorioRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  // =====================================================
  // COMPRAS
  // =====================================================

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

  // =====================================================
  // VENDAS
  // =====================================================

  Future<List<Map<String, dynamic>>> buscarVendasPorPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT
        iv.material_nome,
        iv.tipo_material,
        SUM(iv.quantidade) AS quantidade,
        SUM(iv.subtotal) AS total
      FROM itens_venda iv
      INNER JOIN vendas v
        ON v.id = iv.venda_id
      WHERE v.data >= ?
        AND v.data < ?
      GROUP BY iv.material_nome, iv.tipo_material
      ORDER BY iv.material_nome ASC
      ''',
      [inicio.toIso8601String(), fim.toIso8601String()],
    );

    return resultado;
  }

  Future<double> buscarTotalVendas({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total), 0) AS total
      FROM vendas
      WHERE data >= ?
        AND data < ?
      ''',
      [inicio.toIso8601String(), fim.toIso8601String()],
    );

    return (resultado.first['total'] as num).toDouble();
  }

  // =====================================================
  // GASTOS
  // =====================================================

  Future<List<Map<String, dynamic>>> buscarGastosPorPeriodo({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _database.database;

    final resultado = await db.query(
      'gastos',
      where: 'data >= ? AND data < ?',
      whereArgs: [inicio.toIso8601String(), fim.toIso8601String()],
      orderBy: 'data ASC',
    );

    return resultado;
  }

  Future<double> buscarTotalGastos({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(valor), 0) AS total
      FROM gastos
      WHERE data >= ?
        AND data < ?
      ''',
      [inicio.toIso8601String(), fim.toIso8601String()],
    );

    return (resultado.first['total'] as num).toDouble();
  }

  // =====================================================
  // GERAR RELATÓRIO COMPLETO
  // =====================================================

  Future<RelatorioCompras> gerarRelatorioCompras({
    required DateTime inicio,
    required DateTime fim,
  }) async {
    // -------------------------
    // COMPRAS
    // -------------------------

    final comprasData = await buscarComprasPorPeriodo(inicio: inicio, fim: fim);

    final itensComprados = comprasData.map((item) {
      return ItemRelatorio(
        materialNome: item['material_nome'] as String,
        tipoMaterial: item['tipo_material'] as String,
        quantidade: (item['quantidade'] as num).toDouble(),
        total: (item['total'] as num).toDouble(),
      );
    }).toList();

    final totalCompras = await buscarTotalCompras(inicio: inicio, fim: fim);

    // -------------------------
    // VENDAS
    // -------------------------

    final vendasData = await buscarVendasPorPeriodo(inicio: inicio, fim: fim);

    final itensVendidos = vendasData.map((item) {
      return ItemRelatorio(
        materialNome: item['material_nome'] as String,
        tipoMaterial: item['tipo_material'] as String,
        quantidade: (item['quantidade'] as num).toDouble(),
        total: (item['total'] as num).toDouble(),
      );
    }).toList();

    final totalVendas = await buscarTotalVendas(inicio: inicio, fim: fim);

    // -------------------------
    // GASTOS
    // -------------------------

    final gastosData = await buscarGastosPorPeriodo(inicio: inicio, fim: fim);

    final gastos = gastosData.map((gasto) {
      return GastoRelatorio(
        descricao: gasto['descricao'] as String,
        valor: (gasto['valor'] as num).toDouble(),
        observacao: gasto['observacao'] as String?,
      );
    }).toList();

    final totalGastos = await buscarTotalGastos(inicio: inicio, fim: fim);

    // -------------------------
    // RELATÓRIO
    // -------------------------

    return RelatorioCompras(
      inicio: inicio,
      fim: fim,
      itens: itensComprados,
      totalCompras: totalCompras,
      itensVendidos: itensVendidos,
      totalVendas: totalVendas,
      gastos: gastos,
      totalGastos: totalGastos,
    );
  }
}
