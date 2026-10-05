import '../domain/entities/relatorio_compras.dart';

class RelatorioTexto {
  static String gerar(RelatorioCompras relatorio) {
    final buffer = StringBuffer();

    buffer.writeln('📊 GALPÃO MANAGER');
    buffer.writeln('RELATÓRIO ${_nomePeriodo(relatorio)}');
    buffer.writeln();

    buffer.writeln(
      '${_formatarData(relatorio.inicio)}'
      ' - '
      '${_formatarData(relatorio.fim.subtract(const Duration(days: 1)))}',
    );

    buffer.writeln();

    // =====================================================
    // COMPRAS
    // =====================================================

    buffer.writeln('🛒 COMPRAS');
    buffer.writeln();

    if (relatorio.itens.isEmpty) {
      buffer.writeln('Nenhuma compra registrada.');
    } else {
      for (final item in relatorio.itens) {
        buffer.writeln(
          '• ${item.materialNome} — '
          '${item.quantidade.toStringAsFixed(2)} kg — '
          '${_formatarValor(item.total)}',
        );
      }

      buffer.writeln();
      buffer.writeln(
        'Total de compras: ${_formatarValor(relatorio.totalCompras)}',
      );
    }

    buffer.writeln();
    buffer.writeln('────────────────────');
    buffer.writeln();

    // =====================================================
    // VENDAS
    // =====================================================

    buffer.writeln('💰 VENDAS');
    buffer.writeln();

    if (relatorio.itensVendidos.isEmpty) {
      buffer.writeln('Nenhuma venda registrada.');
    } else {
      for (final item in relatorio.itensVendidos) {
        buffer.writeln(
          '• ${item.materialNome} — '
          '${item.quantidade.toStringAsFixed(2)} kg — '
          '${_formatarValor(item.total)}',
        );
      }

      buffer.writeln();
      buffer.writeln(
        'Total de vendas: ${_formatarValor(relatorio.totalVendas)}',
      );
    }

    buffer.writeln();
    buffer.writeln('────────────────────');
    buffer.writeln();

    // =====================================================
    // GASTOS
    // =====================================================

    buffer.writeln('🧾 GASTOS');
    buffer.writeln();

    if (relatorio.gastos.isEmpty) {
      buffer.writeln('Nenhum gasto registrado.');
    } else {
      for (final gasto in relatorio.gastos) {
        buffer.writeln(
          '• ${gasto.descricao} — '
          '${_formatarValor(gasto.valor)}',
        );
      }

      buffer.writeln();
      buffer.writeln(
        'Total de gastos: ${_formatarValor(relatorio.totalGastos)}',
      );
    }

    buffer.writeln();
    buffer.writeln('────────────────────');
    buffer.writeln();

    // =====================================================
    // RESULTADO
    // =====================================================

    final resultado = relatorio.resultado;

    buffer.writeln('📈 RESULTADO');
    buffer.writeln();

    buffer.writeln('Vendas: ${_formatarValor(relatorio.totalVendas)}');

    buffer.writeln('Compras: ${_formatarValor(relatorio.totalCompras)}');

    buffer.writeln('Gastos: ${_formatarValor(relatorio.totalGastos)}');

    buffer.writeln();

    buffer.writeln('Resultado: ${_formatarValor(resultado)}');

    buffer.writeln();
    buffer.writeln('📊 Gerado pelo Galpão Manager');

    return buffer.toString();
  }

  // =====================================================
  // NOME DO PERÍODO
  // =====================================================

  static String _nomePeriodo(RelatorioCompras relatorio) {
    final quantidadeDias = relatorio.fim.difference(relatorio.inicio).inDays;

    if (quantidadeDias == 1) {
      return 'DIÁRIO';
    }

    if (quantidadeDias == 7) {
      return 'SEMANAL';
    }

    return 'MENSAL';
  }

  // =====================================================
  // DATA
  // =====================================================

  static String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;

    return '$dia/$mes/$ano';
  }

  // =====================================================
  // VALOR
  // =====================================================

  static String _formatarValor(double valor) {
    final sinal = valor < 0 ? '-' : '';
    final valorAbsoluto = valor.abs();

    return '${sinal}R\$ '
        '${valorAbsoluto.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
