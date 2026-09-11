import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/components/cards/gm_stat_card.dart';
import '../../../compras/data/repositories/compra_repository.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_actions.dart';
import '../../../gastos/data/repositories/gasto_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final CompraRepository _compraRepository = CompraRepository();
  final GastoRepository _gastoRepository = GastoRepository();

  double _pesoTotalComprado = 0;
  double _valorTotalComprado = 0;
  double _valorTotalGastos = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final peso = await _compraRepository.calcularPesoTotalComprado();

    final valorCompras = await _compraRepository.calcularValorTotalComprado();

    final valorGastos = await _gastoRepository.calcularValorTotalGastos();

    if (!mounted) return;

    setState(() {
      _pesoTotalComprado = peso;
      _valorTotalComprado = valorCompras;
      _valorTotalGastos = valorGastos;
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
                                value: 'R\$ 0,00',
                                onTap: () {},
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
                                value: '0 kg',
                                onTap: () {},
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      QuickActions(
                        onCompraFinalizada: _carregarDados,
                        onGastoFinalizado: _carregarDados,
                      ),

                      const SizedBox(height: 22),

                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Últimas movimentações',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 12),

                              Text(
                                'Nenhuma movimentação registrada hoje.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),

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
}
