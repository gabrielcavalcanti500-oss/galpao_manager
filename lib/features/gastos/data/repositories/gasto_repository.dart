import '../../../../core/database/app_database.dart';
import '../../domain/entities/gasto.dart';

class GastoRepository {
  final AppDatabase _database;

  GastoRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  Future<int> salvarGasto(Gasto gasto) async {
    final db = await _database.database;

    return await db.insert('gastos', {
      'descricao': gasto.descricao,
      'valor': gasto.valor,
      'data': gasto.data.toIso8601String(),
      'observacao': gasto.observacao,
    });
  }

  Future<List<Gasto>> buscarGastos() async {
    final db = await _database.database;

    final resultado = await db.query('gastos', orderBy: 'data DESC');

    return resultado.map((map) {
      return Gasto(
        id: map['id'] as int,
        descricao: map['descricao'] as String,
        valor: (map['valor'] as num).toDouble(),
        data: DateTime.parse(map['data'] as String),
        observacao: map['observacao'] as String?,
      );
    }).toList();
  }

  Future<void> excluirGasto(int gastoId) async {
    final db = await _database.database;

    await db.delete('gastos', where: 'id = ?', whereArgs: [gastoId]);
  }

  Future<double> calcularValorTotalGastos() async {
    final db = await _database.database;

    final resultado = await db.rawQuery(
      'SELECT COALESCE(SUM(valor), 0) AS total FROM gastos',
    );

    return (resultado.first['total'] as num).toDouble();
  }
}
