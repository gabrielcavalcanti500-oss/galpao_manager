import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/cards/gm_stat_card.dart';
import '../../../compras/data/repositories/compra_repository.dart';
import '../../../gastos/data/repositories/gasto_repository.dart';
import '../../../vendas/data/repositories/venda_repository.dart';
import '../../../estoque/data/repositories/estoque_repository.dart';
import '../../../retiradas/data/repositories/retirada_repository.dart';
import '../../domain/entities/movimentacao.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color _background = Color(0xFFF4F6FA);
  static const Color _navy = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF758195);
  static const Color _green = Color(0xFF16804A);
  static const Color _blue = Color(0xFF2864C5);
  static const Color _orange = Color(0xFFD97706);
  static const Color _purple = Color(0xFF6941C6);
  static const Color _border = Color(0xFFE8EDF3);

  final CompraRepository _compraRepository = CompraRepository();
  final GastoRepository _gastoRepository = GastoRepository();
  final VendaRepository _vendaRepository = VendaRepository();
  final EstoqueRepository _estoqueRepository = EstoqueRepository();
  final RetiradaRepository _retiradaRepository = RetiradaRepository();

  double _pesoTotalComprado = 0;
  double _valorTotalComprado = 0;
  double _valorTotalGastos = 0;
  double _valorTotalVendido = 0;
  double _pesoTotalEstoque = 0;
  int _materiaisComEstoque = 0;

  List<Movimentacao> _ultimasMovimentacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarMovimentacoes();
  }

  Future<void> _carregarDados() async {
    final peso = await _compraRepository.calcularPesoTotalComprado();
    final valorCompras = await _compraRepository.calcularValorTotalComprado();
    final valorGastos = await _gastoRepository.calcularValorGastosMesAtual();
    final valorVendas = await _vendaRepository.calcularValorVendidoMesAtual();
    final materiais = await _estoqueRepository.buscarMateriais();

    double pesoEstoque = 0;
    int materiaisComEstoque = 0;

    for (final material in materiais) {
      final quantidade = await _estoqueRepository.calcularEstoque(material);

      if (quantidade > 0) {
        materiaisComEstoque++;
      }

      if (material.vendidoPorPeso) {
        pesoEstoque += quantidade;
      }
    }

    if (!mounted) return;

    setState(() {
      _pesoTotalComprado = peso;
      _valorTotalComprado = valorCompras;
      _valorTotalGastos = valorGastos;
      _valorTotalVendido = valorVendas;
      _pesoTotalEstoque = pesoEstoque;
      _materiaisComEstoque = materiaisComEstoque;
    });
  }

  Future<void> _carregarMovimentacoes() async {
    final compras = await _compraRepository.buscarCompras();
    final vendas = await _vendaRepository.buscarVendas();
    final gastos = await _gastoRepository.buscarGastos();
    final retiradas = await _retiradaRepository.buscarRetiradas();

    final movimentacoes = <Movimentacao>[];

    for (final compra in compras) {
      final materiais = compra.itens
          .map((item) => item.material.nome)
          .join(', ');

      movimentacoes.add(
        Movimentacao(
          tipo: TipoMovimentacao.compra,
          data: compra.data,
          valor: compra.total,
          descricao: 'Compra #${compra.id}',
          detalhe: materiais,
        ),
      );
    }

    for (final venda in vendas) {
      final materiais = venda.itens
          .map((item) => item.material.nome)
          .join(', ');

      movimentacoes.add(
        Movimentacao(
          tipo: TipoMovimentacao.venda,
          data: venda.data,
          valor: venda.total,
          descricao: 'Venda #${venda.id}',
          detalhe: materiais,
        ),
      );
    }

    for (final gasto in gastos) {
      movimentacoes.add(
        Movimentacao(
          tipo: TipoMovimentacao.gasto,
          data: gasto.data,
          valor: gasto.valor,
          descricao: gasto.descricao,
          detalhe: gasto.observacao,
        ),
      );
    }

    for (final retirada in retiradas) {
      final quantidade = retirada.quantidade % 1 == 0
          ? retirada.quantidade.toStringAsFixed(0)
          : retirada.quantidade.toStringAsFixed(2);

      final unidade = retirada.tipoMaterial.toLowerCase().contains('unidade')
          ? 'unidades'
          : 'kg';

      movimentacoes.add(
        Movimentacao(
          tipo: TipoMovimentacao.retirada,
          data: retirada.data,
          descricao: 'Retirada de ${retirada.materialNome}',
          detalhe: '$quantidade $unidade retirados',
        ),
      );
    }

    movimentacoes.sort((a, b) => b.data.compareTo(a.data));

    if (!mounted) return;

    setState(() {
      _ultimasMovimentacoes = movimentacoes.take(5).toList();
    });
  }

  Future<void> _recarregarDados() async {
    await _carregarDados();
    await _carregarMovimentacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: _recarregarDados,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              const DashboardHeader(),

              const SizedBox(height: 28),

              _buildSectionHeading(
                icon: Icons.space_dashboard_rounded,
                title: 'Resumo operacional',
                subtitle: 'Acompanhe os números do seu galpão',
              ),

              const SizedBox(height: 16),

              _buildIndicators(),

              const SizedBox(height: 30),

              const QuickActions(),

              const SizedBox(height: 30),

              _buildMovementsHeading(),

              const SizedBox(height: 14),

              _buildUltimasMovimentacoes(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeading({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, color: _navy, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 158,
                child: GMStatCard(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Compras',
                  value: '${_pesoTotalComprado.toStringAsFixed(2)} kg',
                  subtitle:
                      'R\$ ${_valorTotalComprado.toStringAsFixed(2)} investidos',
                  accentColor: _green,
                  onTap: () async {
                    await context.push('/historico-compras');
                    await _recarregarDados();
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 158,
                child: GMStatCard(
                  icon: Icons.sell_rounded,
                  title: 'Vendas',
                  value: 'R\$ ${_valorTotalVendido.toStringAsFixed(2)}',
                  accentColor: _blue,
                  onTap: () async {
                    await context.push('/historico-vendas');
                    await _recarregarDados();
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 158,
                child: GMStatCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Gastos',
                  value: 'R\$ ${_valorTotalGastos.toStringAsFixed(2)}',
                  accentColor: _orange,
                  onTap: () async {
                    await context.push('/historico-gastos');
                    await _recarregarDados();
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 158,
                child: GMStatCard(
                  icon: Icons.warehouse_rounded,
                  title: 'Estoque',
                  value: '${_pesoTotalEstoque.toStringAsFixed(2)} kg',
                  subtitle: '$_materiaisComEstoque materiais disponíveis',
                  accentColor: _purple,
                  onTap: () async {
                    await context.push('/estoque');
                    await _recarregarDados();
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMovementsHeading() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.history_rounded, color: _navy, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Últimas movimentações',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: _navy,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Atividades recentes do galpão',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => context.go('/relatorios'),
          style: TextButton.styleFrom(
            foregroundColor: _green,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          ),
          child: const Text(
            'Relatórios',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildUltimasMovimentacoes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _ultimasMovimentacoes.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 38,
                      color: Color(0xFFB3BECC),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Nenhuma movimentação registrada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: List.generate(
                _ultimasMovimentacoes.length,
                (index) => Column(
                  children: [
                    _buildMovimentacaoItem(_ultimasMovimentacoes[index]),
                    if (index < _ultimasMovimentacoes.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.7,
                        color: Color(0xFFF0F2F6),
                        indent: 56,
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMovimentacaoItem(Movimentacao movimentacao) {
    final config = _configurarMovimentacao(movimentacao.tipo);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: config.$2.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(config.$1, color: config.$2, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimentacao.descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _navy,
                  ),
                ),
                if (movimentacao.detalhe != null &&
                    movimentacao.detalhe!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    movimentacao.detalhe!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  _formatarDataHora(movimentacao.data),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9AA5B5),
                  ),
                ),
              ],
            ),
          ),
          if (movimentacao.valor != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'R\$ ${movimentacao.valor!.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: config.$2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  (IconData, Color) _configurarMovimentacao(TipoMovimentacao tipo) {
    switch (tipo) {
      case TipoMovimentacao.compra:
        return (Icons.shopping_cart_rounded, _green);
      case TipoMovimentacao.venda:
        return (Icons.sell_rounded, _blue);
      case TipoMovimentacao.gasto:
        return (Icons.receipt_long_rounded, _orange);
      case TipoMovimentacao.retirada:
        return (Icons.inventory_2_rounded, const Color(0xFFB45309));
    }
  }

  String _formatarDataHora(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes às $hora:$minuto';
  }
}
