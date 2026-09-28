import 'package:flutter/material.dart';

import '../../data/repositories/estoque_repository.dart';
import '../../../compras/domain/entities/material_model.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  final EstoqueRepository _estoqueRepository = EstoqueRepository();

  late Future<List<_EstoqueItem>> _estoqueFuture;

  @override
  void initState() {
    super.initState();
    _carregarEstoque();
  }

  void _carregarEstoque() {
    setState(() {
      _estoqueFuture = _buscarEstoque();
    });
  }

  Future<List<_EstoqueItem>> _buscarEstoque() async {
    final materiais = await _estoqueRepository.buscarMateriais();

    final List<_EstoqueItem> estoque = [];

    for (final material in materiais) {
      final quantidade = await _estoqueRepository.calcularEstoque(material);

      estoque.add(_EstoqueItem(material: material, quantidade: quantidade));
    }

    return estoque;
  }

  String _formatarQuantidade(MaterialModel material, double quantidade) {
    if (material.vendidoPorUnidade) {
      return '${quantidade.toStringAsFixed(0)} un';
    }

    return '${quantidade.toStringAsFixed(2)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(title: const Text('Estoque'), centerTitle: true),
      body: FutureBuilder<List<_EstoqueItem>>(
        future: _estoqueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar o estoque.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _carregarEstoque,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final estoque = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              _carregarEstoque();
              await _estoqueFuture;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildResumo(estoque),
                const SizedBox(height: 20),
                const Text(
                  'Materiais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...estoque.map(_buildMaterialCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumo(List<_EstoqueItem> estoque) {
    final materiaisComEstoque = estoque
        .where((item) => item.quantidade > 0)
        .length;

    final materiaisZerados = estoque
        .where((item) => item.quantidade <= 0)
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff0B7A3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _resumoItem(
              Icons.inventory_2_rounded,
              materiaisComEstoque.toString(),
              'Com estoque',
            ),
          ),
          Container(width: 1, height: 42, color: Colors.white24),
          Expanded(
            child: _resumoItem(
              Icons.remove_shopping_cart_rounded,
              materiaisZerados.toString(),
              'Sem estoque',
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumoItem(IconData icon, String valor, String titulo) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 6),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMaterialCard(_EstoqueItem item) {
    final possuiEstoque = item.quantidade > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffEAF7EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.material.vendidoPorUnidade
                  ? Icons.inventory_2_rounded
                  : Icons.scale_rounded,
              color: const Color(0xff0B7A3E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.material.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.material.vendidoPorUnidade
                      ? 'Controle por unidade'
                      : 'Controle por peso',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          Text(
            _formatarQuantidade(item.material, item.quantidade),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: possuiEstoque ? const Color(0xff0B7A3E) : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstoqueItem {
  final MaterialModel material;
  final double quantidade;

  const _EstoqueItem({required this.material, required this.quantidade});
}
