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

  DateTime? _dataInicialSelecionada;
  DateTime? _dataFinalSelecionada;
  bool _usarDatasPersonalizadas = false;

  String _filtroTipo = 'Todos';

  final TextEditingController _buscaController = TextEditingController();

  final List<String> _tiposFiltro = ['Todos', 'Compras', 'Vendas', 'Gastos'];

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarRelatorio();
  }

  Future<void> _selecionarDataInicial() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicialSelecionada ?? hoje,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data inicial',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (data == null || !mounted) return;

    setState(() {
      _dataInicialSelecionada = data;
    });
  }

  Future<void> _selecionarDataFinal() async {
    final hoje = DateTime.now();
    final inicial = _dataInicialSelecionada;

    final data = await showDatePicker(
      context: context,
      initialDate: _dataFinalSelecionada ?? inicial ?? hoje,
      firstDate: inicial ?? DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data final',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (data == null || !mounted) return;

    setState(() {
      _dataFinalSelecionada = data;
    });
  }

  Future<void> _pesquisarDatas() async {
    final inicio = _dataInicialSelecionada;
    final finalSelecionada = _dataFinalSelecionada;

    if (inicio == null || finalSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data inicial e a data final.'),
        ),
      );
      return;
    }

    if (finalSelecionada.isBefore(inicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data final não pode ser anterior à data inicial.'),
        ),
      );
      return;
    }

    setState(() {
      _usarDatasPersonalizadas = true;
      _carregando = true;
    });

    try {
      final relatorio = await _repository.gerarRelatorioCompras(
        inicio: DateTime(inicio.year, inicio.month, inicio.day),
        fim: DateTime(
          finalSelecionada.year,
          finalSelecionada.month,
          finalSelecionada.day + 1,
        ),
      );

      if (!mounted) return;

      setState(() {
        _relatorio = relatorio;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar o relatório.')),
      );
    }
  }

  // =====================================================
  // CARREGAR RELATÓRIO
  // =====================================================

  Future<void> _carregarRelatorio() async {
    if (_usarDatasPersonalizadas) {
      final inicioSelecionado = _dataInicialSelecionada;
      final fimSelecionado = _dataFinalSelecionada;

      if (inicioSelecionado == null || fimSelecionado == null) {
        setState(() {
          _carregando = false;
        });
        return;
      }

      setState(() {
        _carregando = true;
      });

      try {
        final relatorio = await _repository.gerarRelatorioCompras(
          inicio: DateTime(
            inicioSelecionado.year,
            inicioSelecionado.month,
            inicioSelecionado.day,
          ),
          fim: DateTime(
            fimSelecionado.year,
            fimSelecionado.month,
            fimSelecionado.day + 1,
          ),
        );

        if (!mounted) return;

        setState(() {
          _relatorio = relatorio;
          _carregando = false;
        });
      } catch (_) {
        if (!mounted) return;

        setState(() {
          _carregando = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível atualizar o relatório.'),
          ),
        );
      }

      return;
    }

    setState(() {
      _carregando = true;
    });

    final agora = DateTime.now();

    late DateTime inicio;
    late DateTime fim;

    if (_periodoSelecionado == 'Diário') {
      inicio = DateTime(agora.year, agora.month, agora.day);
      fim = inicio.add(const Duration(days: 1));
    } else if (_periodoSelecionado == 'Semanal') {
      final hoje = DateTime(agora.year, agora.month, agora.day);
      inicio = hoje.subtract(Duration(days: hoje.weekday - 1));
      fim = inicio.add(const Duration(days: 7));
    } else {
      inicio = DateTime(agora.year, agora.month, 1);
      fim = DateTime(agora.year, agora.month + 1, 1);
    }

    try {
      final relatorio = await _repository.gerarRelatorioCompras(
        inicio: inicio,
        fim: fim,
      );

      if (!mounted) return;

      setState(() {
        _relatorio = relatorio;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar o relatório.')),
      );
    }
  }

  // =====================================================
  // TROCAR PERÍODO
  // =====================================================

  void _alterarPeriodo(String periodo) {
    setState(() {
      _periodoSelecionado = periodo;
      _usarDatasPersonalizadas = false;
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

      appBar: AppBar(
        backgroundColor: const Color(0xFF172B4D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatórios',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2),
            Text(
              'Acompanhe os resultados do galpão',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFD5DEEB),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
    final busca = _buscaController.text.trim().toLowerCase();

    final itensComprados = relatorio.itens.where((item) {
      return item.materialNome.toLowerCase().contains(busca);
    }).toList();

    final itensVendidos = relatorio.itensVendidos.where((item) {
      return item.materialNome.toLowerCase().contains(busca);
    }).toList();

    final gastosFiltrados = relatorio.gastos.where((gasto) {
      return gasto.descricao.toLowerCase().contains(busca) ||
          (gasto.observacao ?? '').toLowerCase().contains(busca);
    }).toList();

    final mostrarCompras = _filtroTipo == 'Todos' || _filtroTipo == 'Compras';
    final mostrarVendas = _filtroTipo == 'Todos' || _filtroTipo == 'Vendas';
    final mostrarGastos = _filtroTipo == 'Todos' || _filtroTipo == 'Gastos';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Relatórios',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildSeletorPeriodo(),
        const SizedBox(height: 16),

        _buildFiltroDatas(),
        const SizedBox(height: 16),

        _buildFiltrosResultados(),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF3468D4),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Período consultado',
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatarPeriodo(relatorio.inicio, relatorio.fim),
                      style: const TextStyle(
                        color: Color(0xFF172B4D),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // O resumo financeiro continua representando o período inteiro.
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

        // COMPRAS
        if (mostrarCompras) ...[
          _buildTituloSecao(
            icon: Icons.shopping_cart_rounded,
            titulo: 'Compras',
            cor: Colors.green,
          ),
          const SizedBox(height: 12),
          if (itensComprados.isEmpty)
            _buildSemMovimentacoes(
              busca.isEmpty
                  ? 'Nenhuma compra registrada neste período.'
                  : 'Nenhuma compra encontrada para essa busca.',
            )
          else
            ...itensComprados.map(_buildItemCompra),
          const SizedBox(height: 24),
        ],

        // VENDAS
        if (mostrarVendas) ...[
          _buildTituloSecao(
            icon: Icons.sell_rounded,
            titulo: 'Vendas',
            cor: Colors.blue,
          ),
          const SizedBox(height: 12),
          if (itensVendidos.isEmpty)
            _buildSemMovimentacoes(
              busca.isEmpty
                  ? 'Nenhuma venda registrada neste período.'
                  : 'Nenhuma venda encontrada para essa busca.',
            )
          else
            ...itensVendidos.map(_buildItemVenda),
          const SizedBox(height: 24),
        ],

        // GASTOS
        if (mostrarGastos) ...[
          _buildTituloSecao(
            icon: Icons.receipt_long_rounded,
            titulo: 'Gastos',
            cor: Colors.orange,
          ),
          const SizedBox(height: 12),
          if (gastosFiltrados.isEmpty)
            _buildSemMovimentacoes(
              busca.isEmpty
                  ? 'Nenhum gasto registrado neste período.'
                  : 'Nenhum gasto encontrado para essa busca.',
            )
          else
            ...gastosFiltrados.map(_buildGasto),
          const SizedBox(height: 24),
        ],

        // RESULTADO FINANCEIRO DO PERÍODO COMPLETO
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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EAF0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: _periodos.map((periodo) {
          final selecionado = _periodoSelecionado == periodo;

          return Expanded(
            child: GestureDetector(
              onTap: selecionado ? null : () => _alterarPeriodo(periodo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: selecionado
                      ? const Color(0xFF16865B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (selecionado) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        periodo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selecionado
                              ? Colors.white
                              : const Color(0xFF718096),
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildFiltroDatas() {
    String formatar(DateTime? data) {
      if (data == null) return 'Selecionar data';

      return _formatarData(data);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.date_range_rounded, color: Color(0xFF3468D4)),
              SizedBox(width: 8),
              Text(
                'Período personalizado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172B4D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _botaoData(
                  titulo: 'Data inicial',
                  data: formatar(_dataInicialSelecionada),
                  onTap: _selecionarDataInicial,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _botaoData(
                  titulo: 'Data final',
                  data: formatar(_dataFinalSelecionada),
                  onTap: _selecionarDataFinal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _carregando ? null : _pesquisarDatas,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF172B4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text(
                'Pesquisar período',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoData({
    required String titulo,
    required String data,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3EAF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: Color(0xFF3468D4),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF172B4D),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltrosResultados() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar resultados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tiposFiltro.map((tipo) {
              final selecionado = _filtroTipo == tipo;

              return ChoiceChip(
                label: Text(tipo),
                selected: selecionado,
                onSelected: (_) {
                  setState(() {
                    _filtroTipo = tipo;
                  });
                },
                selectedColor: const Color(0xFFE8F6EF),
                labelStyle: TextStyle(
                  color: selecionado
                      ? const Color(0xFF16865B)
                      : const Color(0xFF718096),
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: selecionado
                      ? const Color(0xFF16865B)
                      : const Color(0xFFE3EAF0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _buscaController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar material ou descrição...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _buscaController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _buscaController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: const Color(0xFFF5F7FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
