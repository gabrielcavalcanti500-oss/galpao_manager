import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/cards/gm_stat_card.dart';
import '../../../compras/data/repositories/compra_repository.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions.dart';
import '../../../gastos/data/repositories/gasto_repository.dart';
import '../../../vendas/data/repositories/venda_repository.dart';
import '../../../estoque/data/repositories/estoque_repository.dart';
import '../../domain/entities/movimentacao.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CompraRepository _compraRepository = CompraRepository();
  final GastoRepository _gastoRepository = GastoRepository();
  final VendaRepository _vendaRepository = VendaRepository();
  final EstoqueRepository _estoqueRepository = EstoqueRepository();

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

    final valorGastos = await _gastoRepository.calcularValorTotalGastos();

    final valorVendas = await _vendaRepository.calcularValorTotalVendido();

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

    movimentacoes.sort((a, b) => b.data.compareTo(a.data));

    if (!mounted) return;

    setState(() {
      _ultimasMovimentacoes = movimentacoes.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const DashboardHeader(),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 145,
                              child: GMStatCard(
                                icon: Icons.shopping_cart_rounded,
                                title: 'Compras',
                                value:
                                    '${_pesoTotalComprado.toStringAsFixed(2)} kg',
                                subtitle:
                                    'R\$ ${_valorTotalComprado.toStringAsFixed(2)} investidos',
                                onTap: () async {
                                  await context.push('/historico-compras');
                                  _carregarDados();
                                  _carregarMovimentacoes();
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: SizedBox(
                              height: 145,
                              child: GMStatCard(
                                icon: Icons.sell_rounded,
                                title: 'Vendas',
                                value:
                                    'R\$ ${_valorTotalVendido.toStringAsFixed(2)}',
                                onTap: () async {
                                  await context.push('/historico-vendas');

                                  _carregarDados();
                                  _carregarMovimentacoes();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 145,
                              child: GMStatCard(
                                icon: Icons.receipt_long_rounded,
                                title: 'Gastos',
                                value:
                                    'R\$ ${_valorTotalGastos.toStringAsFixed(2)}',
                                onTap: () async {
                                  await context.push('/historico-gastos');

                                  _carregarDados();
                                  _carregarMovimentacoes();
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: SizedBox(
                              height: 145,
                              child: GMStatCard(
                                icon: Icons.warehouse_rounded,
                                title: 'Estoque',
                                value:
                                    '${_pesoTotalEstoque.toStringAsFixed(2)} kg',
                                subtitle:
                                    '$_materiaisComEstoque materiais em estoque',
                                onTap: () async {
                                  await context.push('/estoque');
                                  _carregarDados();
                                  _carregarMovimentacoes();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      QuickActions(
                        onCompraFinalizada: () {
                          _carregarDados();
                          _carregarMovimentacoes();
                        },
                        onVendaFinalizada: () {
                          _carregarDados();
                          _carregarMovimentacoes();
                        },
                        onGastoFinalizado: () {
                          _carregarDados();
                          _carregarMovimentacoes();
                        },
                      ),

                      const SizedBox(height: 22),

                      _buildUltimasMovimentacoes(),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltimasMovimentacoes() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas movimentações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_ultimasMovimentacoes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhuma movimentação registrada.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ..._ultimasMovimentacoes.map(_buildMovimentacaoItem),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimentacaoItem(Movimentacao movimentacao) {
    final config = _configurarMovimentacao(movimentacao.tipo);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffEAF7EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.$1, color: const Color(0xff0B7A3E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movimentacao.descricao,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (movimentacao.detalhe != null &&
                    movimentacao.detalhe!.isNotEmpty)
                  Text(
                    movimentacao.detalhe!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                const SizedBox(height: 2),
                Text(
                  _formatarDataHora(movimentacao.data),
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'R\$ ${movimentacao.valor.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: config.$2),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _configurarMovimentacao(TipoMovimentacao tipo) {
    switch (tipo) {
      case TipoMovimentacao.compra:
        return (Icons.shopping_cart_rounded, const Color(0xff0B7A3E));

      case TipoMovimentacao.venda:
        return (Icons.sell_rounded, const Color(0xff0B7A3E));

      case TipoMovimentacao.gasto:
        return (Icons.receipt_long_rounded, const Color(0xff0B7A3E));
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
