import 'package:flutter/material.dart';

import '../../../compras/data/materials_data.dart';
import '../../../compras/domain/entities/material_model.dart';
import '../../data/repositories/retirada_repository.dart';
import '../../domain/entities/retirada.dart';
import '../../../estoque/data/repositories/estoque_repository.dart';

class RetiradaPage extends StatefulWidget {
  const RetiradaPage({super.key});

  @override
  State<RetiradaPage> createState() => _RetiradaPageState();
}

class _RetiradaPageState extends State<RetiradaPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();

  final _estoqueRepository = EstoqueRepository();
  final _retiradaRepository = RetiradaRepository();

  MaterialModel? _materialSelecionado;
  double _estoqueDisponivel = 0;
  bool _carregandoEstoque = false;
  bool _salvando = false;

  Future<void> _selecionarMaterial(MaterialModel? material) async {
    if (material == null) return;

    setState(() {
      _materialSelecionado = material;
      _estoqueDisponivel = 0;
      _carregandoEstoque = true;
      _quantidadeController.clear();
    });

    try {
      final estoque = await _estoqueRepository.calcularEstoque(material);

      if (!mounted) return;

      setState(() {
        _estoqueDisponivel = estoque;
        _carregandoEstoque = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregandoEstoque = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível consultar o estoque.')),
      );
    }
  }

  void _retirarTudo() {
    if (_estoqueDisponivel <= 0) return;

    _quantidadeController.text = _estoqueDisponivel.toStringAsFixed(2);
  }

  Future<void> _salvarRetirada() async {
    if (!_formKey.currentState!.validate()) return;

    final material = _materialSelecionado;
    if (material == null) return;

    final quantidade = double.parse(
      _quantidadeController.text.trim().replaceAll(',', '.'),
    );

    setState(() => _salvando = true);

    try {
      await _retiradaRepository.salvarRetirada(
        Retirada(
          materialNome: material.nome,
          tipoMaterial: material.tipo.name,
          quantidade: quantidade,
          data: DateTime.now(),
        ),
      );

      if (!mounted) return;

      setState(() {
        _salvando = false;
        _estoqueDisponivel = (_estoqueDisponivel - quantidade).clamp(
          0.0,
          double.infinity,
        );
        _quantidadeController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retirada registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (erro) {
      if (!mounted) return;

      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Bad state: ', '')),
          backgroundColor: Colors.red,
        ),
      );

      // Atualiza o estoque exibido após uma tentativa inválida.
      await _selecionarMaterial(material);
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final material = _materialSelecionado;
    final unidade = material?.vendidoPorUnidade == true ? 'unidades' : 'kg';

    return Scaffold(
      appBar: AppBar(title: const Text('Retirada de material')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 54),
                const SizedBox(height: 12),
                Text(
                  'Registrar retirada',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Informe o material e a quantidade que saiu do galpão.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                DropdownButtonFormField<MaterialModel>(
                  value: _materialSelecionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Material',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: materiais.map((item) {
                    return DropdownMenuItem<MaterialModel>(
                      value: item,
                      child: Text(item.nome),
                    );
                  }).toList(),
                  onChanged: _salvando ? null : _selecionarMaterial,
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione um material.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.warehouse_outlined, size: 30),
                        const SizedBox(height: 8),
                        const Text('Estoque disponível'),
                        const SizedBox(height: 6),
                        if (_carregandoEstoque)
                          const CircularProgressIndicator()
                        else
                          Text(
                            material == null
                                ? 'Selecione um material'
                                : '${_estoqueDisponivel.toStringAsFixed(2)} $unidade',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _quantidadeController,
                  enabled:
                      !_salvando && material != null && !_carregandoEstoque,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Quantidade a retirar',
                    hintText: 'Ex.: 10,5',
                    suffixText: unidade,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (material == null) {
                      return 'Selecione um material.';
                    }

                    if (_estoqueDisponivel <= 0) {
                      return 'Não há estoque disponível.';
                    }

                    final texto = value?.trim().replaceAll(',', '.');

                    if (texto == null || texto.isEmpty) {
                      return 'Informe a quantidade.';
                    }

                    final quantidade = double.tryParse(texto);

                    if (quantidade == null || !quantidade.isFinite) {
                      return 'Informe uma quantidade válida.';
                    }

                    if (quantidade <= 0) {
                      return 'A quantidade deve ser maior que zero.';
                    }

                    if (quantidade > _estoqueDisponivel) {
                      return 'A quantidade supera o estoque disponível.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed:
                      _salvando ||
                          material == null ||
                          _carregandoEstoque ||
                          _estoqueDisponivel <= 0
                      ? null
                      : _retirarTudo,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Retirar todo o estoque'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _salvando || _carregandoEstoque
                      ? null
                      : _salvarRetirada,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_salvando ? 'Salvando...' : 'Confirmar retirada'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
