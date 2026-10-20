import '../../../../core/database/app_database.dart';
import '../../domain/entities/retirada.dart';

class RetiradaRepository {
  final AppDatabase _database;

  RetiradaRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  Future<int> salvarRetirada(Retirada retirada) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      final quantidadeRetirada = retirada.quantidade;

      if (quantidadeRetirada <= 0) {
        throw ArgumentError('A quantidade retirada deve ser maior que zero.');
      }

      // Calcula as quantidades compradas, vendidas e retiradas.
      // Todas as consultas usam a mesma transação do registro.
      final compras = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(quantidade), 0) AS total
        FROM itens_compra
        WHERE material_nome = ?
        ''',
        [retirada.materialNome],
      );

      final vendas = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(quantidade), 0) AS total
        FROM itens_venda
        WHERE material_nome = ?
        ''',
        [retirada.materialNome],
      );

      final retiradas = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(quantidade), 0) AS total
        FROM retiradas
        WHERE material_nome = ?
        ''',
        [retirada.materialNome],
      );

      final quantidadeComprada = (compras.first['total'] as num).toDouble();

      final quantidadeVendida = (vendas.first['total'] as num).toDouble();

      final quantidadeJaRetirada = (retiradas.first['total'] as num).toDouble();

      final estoqueDisponivel =
          quantidadeComprada - quantidadeVendida - quantidadeJaRetirada;

      if (estoqueDisponivel <= 0) {
        throw StateError(
          'Não existe estoque disponível de '
          '${retirada.materialNome}.',
        );
      }

      if (quantidadeRetirada > estoqueDisponivel) {
        final unidade = retirada.tipoMaterial.toLowerCase().contains('unidade')
            ? 'unidades'
            : 'kg';

        throw StateError(
          'Estoque insuficiente de ${retirada.materialNome}. '
          'Disponível: ${estoqueDisponivel.toStringAsFixed(2)} '
          '$unidade.',
        );
      }

      // Registra a retirada sem alterar compras ou vendas.
      return txn.insert('retiradas', {
        'material_nome': retirada.materialNome,
        'tipo_material': retirada.tipoMaterial,
        'quantidade': quantidadeRetirada,
        'data': retirada.data.toIso8601String(),
      });
    });
  }

  Future<List<Retirada>> buscarRetiradas() async {
    final db = await _database.database;

    final resultados = await db.query(
      'retiradas',
      orderBy: 'data DESC, id DESC',
    );

    return resultados.map((item) {
      return Retirada(
        id: item['id'] as int,
        materialNome: item['material_nome'] as String,
        tipoMaterial: item['tipo_material'] as String,
        quantidade: (item['quantidade'] as num).toDouble(),
        data: DateTime.parse(item['data'] as String),
      );
    }).toList();
  }

  Future<void> excluirRetirada(int id) async {
    final db = await _database.database;

    await db.delete('retiradas', where: 'id = ?', whereArgs: [id]);
  }
}
