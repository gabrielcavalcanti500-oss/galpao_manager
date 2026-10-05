import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/relatorio_repository.dart';
import '../../domain/entities/item_relatorio.dart';
import '../../domain/entities/relatorio_compras.dart';
import '../../utils/relatorio_texto.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  final RelatorioRepository _repository = RelatorioRepository();

  RelatorioCompras? _relatorio;
  bool _carregando = true;

  String _periodoSelecionado = 'Diário';

  final List<String> _periodos = ['Diário', 'Semanal', 'Mensal'];

  @override
  void initState() {
    super.initState();
    _carregarRelatorio();
  }

  // =====================================================
  // CARREGAR RELATÓRIO
  // =====================================================

  Future<void> _carregarRelatorio() async {
    setState(() {
      _carregando = true;
    });

    final agora = DateTime.now();

    late DateTime inicio;
    late DateTime fim;

    // ===================================================
    // DIÁRIO
    // ===================================================

    if (_periodoSelecionado == 'Diário') {
      inicio = DateTime(agora.year, agora.month, agora.day);

      fim = inicio.add(const Duration(days: 1));
    }
    // ===================================================
    // SEMANAL
    // ===================================================
    else if (_periodoSelecionado == 'Semanal') {
      final hoje = DateTime(agora.year, agora.month, agora.day);

      // DateTime.weekday:
      // segunda = 1
      // domingo = 7

      inicio = hoje.subtract(Duration(days: hoje.weekday - 1));

      fim = inicio.add(const Duration(days: 7));
    }
    // ===================================================
    // MENSAL
    // ===================================================
    else {
      inicio = DateTime(agora.year, agora.month, 1);

      fim = DateTime(agora.year, agora.month + 1, 1);
    }

    final relatorio = await _repository.gerarRelatorioCompras(
      inicio: inicio,
      fim: fim,
    );

    if (!mounted) return;

    setState(() {
      _relatorio = relatorio;
      _carregando = false;
    });
  }

  // =====================================================
  // TROCAR PERÍODO
  // =====================================================

  void _alterarPeriodo(String periodo) {
    setState(() {
      _periodoSelecionado = periodo;
    });

    _carregarRelatorio();
  }

  Future<void> _compartilharRelatorio() async {
    final relatorio = _relatorio;

    if (relatorio == null) return;

    final texto = RelatorioTexto.gerar(relatorio);

    await SharePlus.instance.share(
      ShareParams(text: texto, subject: 'Relatório Galpão Manager'),
    );
  }

  // =====================================================
  // FORMATAÇÃO
  // =====================================================

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;

    return '$dia/$mes/$ano';
  }

  String _formatarPeriodo(DateTime inicio, DateTime fim) {
    final fimReal = fim.subtract(const Duration(days: 1));

    if (_periodoSelecionado == 'Diário') {
      return _formatarData(inicio);
    }

    if (_periodoSelecionado == 'Semanal') {
      return '${_formatarData(inicio)} - ${_formatarData(fimReal)}';
    }

    return '${_formatarData(inicio)} - ${_formatarData(fimReal)}';
  }

  String _formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(title: const Text('Relatórios'), centerTitle: true),

      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarRelatorio,
              child: _buildConteudo(),
            ),
    );
  }

  // =====================================================
  // CONTEÚDO
  // =====================================================

  Widget _buildConteudo() {
    final relatorio = _relatorio!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Relatórios',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // =================================================
        // SELETOR DE PERÍODO
        // =================================================
        _buildSeletorPeriodo(),

        const SizedBox(height: 16),

        Text(
          _formatarPeriodo(relatorio.inicio, relatorio.fim),
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),

        const SizedBox(height: 20),

        // =================================================
        // RESUMO
        // =================================================
        _buildResumo(relatorio),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _compartilharRelatorio,
            icon: const Icon(Icons.share_rounded),
            label: const Text('Compartilhar relatório'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // =================================================
        // COMPRAS
        // =================================================
        _buildTituloSecao(
          icon: Icons.shopping_cart_rounded,
          titulo: 'Compras',
          cor: Colors.green,
        ),

        const SizedBox(height: 12),

        if (relatorio.itens.isEmpty)
          _buildSemMovimentacoes('Nenhuma compra registrada neste período.')
        else
          ...relatorio.itens.map(_buildItemCompra),

        const SizedBox(height: 24),

        // =================================================
        // VENDAS
        // =================================================
        _buildTituloSecao(
          icon: Icons.sell_rounded,
          titulo: 'Vendas',
          cor: Colors.blue,
        ),

        const SizedBox(height: 12),

        if (relatorio.itensVendidos.isEmpty)
          _buildSemMovimentacoes('Nenhuma venda registrada neste período.')
        else
          ...relatorio.itensVendidos.map(_buildItemVenda),

        const SizedBox(height: 24),

        // =================================================
        // GASTOS
        // =================================================
        _buildTituloSecao(
          icon: Icons.receipt_long_rounded,
          titulo: 'Gastos',
          cor: Colors.orange,
        ),

        const SizedBox(height: 12),

        if (relatorio.gastos.isEmpty)
          _buildSemMovimentacoes('Nenhum gasto registrado neste período.')
        else
          ...relatorio.gastos.map(_buildGasto),

        const SizedBox(height: 24),

        // =================================================
        // RESULTADO
        // =================================================
        _buildResultado(relatorio),

        const SizedBox(height: 20),
      ],
    );
  }

  // =====================================================
  // SELETOR
  // =====================================================

  Widget _buildSeletorPeriodo() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _periodos.map((periodo) {
          final selecionado = _periodoSelecionado == periodo;

          return Expanded(
            child: GestureDetector(
              onTap: () => _alterarPeriodo(periodo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selecionado ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  periodo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selecionado ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =====================================================
  // RESUMO
  // =====================================================

  Widget _buildResumo(RelatorioCompras relatorio) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildResumoLinha(
              icon: Icons.shopping_cart_rounded,
              titulo: 'Compras',
              valor: relatorio.totalCompras,
              cor: Colors.green,
            ),

            const Divider(height: 24),

            _buildResumoLinha(
              icon: Icons.sell_rounded,
              titulo: 'Vendas',
              valor: relatorio.totalVendas,
              cor: Colors.blue,
            ),

            const Divider(height: 24),

            _buildResumoLinha(
              icon: Icons.receipt_long_rounded,
              titulo: 'Gastos',
              valor: relatorio.totalGastos,
              cor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoLinha({
    required IconData icon,
    required String titulo,
    required double valor,
    required Color cor,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cor),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),

        Text(
          _formatarValor(valor),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // =====================================================
  // TÍTULO DAS SEÇÕES
  // =====================================================

  Widget _buildTituloSecao({
    required IconData icon,
    required String titulo,
    required Color cor,
  }) {
    return Row(
      children: [
        Icon(icon, color: cor, size: 22),

        const SizedBox(width: 8),

        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // =====================================================
  // ITEM DE COMPRA
  // =====================================================

  Widget _buildItemCompra(ItemRelatorio item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: Colors.green),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.materialNome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${item.quantidade.toStringAsFixed(2)} kg',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),

            Text(
              _formatarValor(item.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ITEM DE VENDA
  // =====================================================

  Widget _buildItemVenda(ItemRelatorio item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: Colors.blue),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.materialNome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${item.quantidade.toStringAsFixed(2)} kg',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),

            Text(
              _formatarValor(item.total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // GASTO
  // =====================================================

  Widget _buildGasto(GastoRelatorio gasto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: Colors.orange),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gasto.descricao,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  if (gasto.observacao != null &&
                      gasto.observacao!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      gasto.observacao!,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Text(
              _formatarValor(gasto.valor),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // RESULTADO
  // =====================================================

  Widget _buildResultado(RelatorioCompras relatorio) {
    final resultado = relatorio.resultado;
    final positivo = resultado >= 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado do período',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              _formatarValor(resultado),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: positivo ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Vendas - Compras - Gastos',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SEM MOVIMENTAÇÕES
  // =====================================================

  Widget _buildSemMovimentacoes(String mensagem) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: Colors.black26,
            ),

            const SizedBox(height: 10),

            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
