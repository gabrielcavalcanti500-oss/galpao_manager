import 'package:sqflite/sqflite.dart';

import 'lib/core/database/app_database.dart';

Future<void> main() async {
  final db = await AppDatabase.instance.database;

  final retiradas = await db.query('retiradas', orderBy: 'data DESC, id DESC');

  print('\n===== RETIRADAS REGISTRADAS =====');

  for (final retirada in retiradas) {
    print(
      'ID: ${retirada['id']} | '
      'Material: ${retirada['material_nome']} | '
      'Quantidade: ${retirada['quantidade']} | '
      'Data: ${retirada['data']}',
    );
  }

  print('\n===== FIM DA CONSULTA =====');
  await db.close();
}
