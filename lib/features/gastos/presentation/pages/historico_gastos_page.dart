import 'package:flutter/material.dart';

import '../../data/repositories/gasto_repository.dart';
import '../../domain/entities/gasto.dart';

class HistoricoGastosPage extends StatefulWidget {
  const HistoricoGastosPage({super.key});

  @override
  State<HistoricoGastosPage> createState() => _HistoricoGastosPageState();
}

class _HistoricoGastosPageState extends State<HistoricoGastosPage> {
  final GastoRepository _repository = GastoRepository();

  late Future<List<Gasto>> _gastosFuture;

  @override
  void initState() {
    super.initState();
    _carregarGastos();
  }

  void _carregarGastos() {
    _gastosFuture = _repository.buscarGastos();
  }

  Future<void> _atualizar() async {
    setState(() {
      _carregarGastos();
    });

    await _gastosFuture;
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;

    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano • $hora:$minuto';
  }

  Future<void> _confirmarExclusao(Gasto gasto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir gasto?'),
          content: Text('Deseja realmente excluir "${gasto.descricao}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || gasto.id == null) return;

    await _repository.excluirGasto(gasto.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gasto excluído com sucesso!')),
    );

    await _atualizar();
  }

  void _mostrarDetalhes(Gasto gasto) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gasto.descricao,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _formatarData(gasto.data),
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 20),

              const Text('Valor', style: TextStyle(color: Colors.black54)),

              const SizedBox(height: 4),

              Text(
                'R\$ ${gasto.valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

              if (gasto.observacao != null && gasto.observacao!.isNotEmpty) ...[
                const SizedBox(height: 24),

                const Text(
                  'Observação',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  gasto.observacao!,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text('Histórico de Gastos'),
        centerTitle: true,
      ),

      body: FutureBuilder<List<Gasto>>(
        future: _gastosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar os gastos.'),
            );
          }

          final gastos = snapshot.data ?? [];

          if (gastos.isEmpty) {
            return RefreshIndicator(
              onRefresh: _atualizar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),

                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Nenhum gasto encontrado',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Os gastos registrados aparecerão aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: gastos.length,
              itemBuilder: (context, index) {
                final gasto = gastos[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _mostrarDetalhes(gasto),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.red,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gasto.descricao,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  _formatarData(gasto.data),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),

                                if (gasto.observacao != null &&
                                    gasto.observacao!.isNotEmpty) ...[
                                  const SizedBox(height: 6),

                                  const Text(
                                    'Possui observação',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'R\$ ${gasto.valor.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Excluir gasto',
                                    onPressed: () => _confirmarExclusao(gasto),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),

                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 15,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
