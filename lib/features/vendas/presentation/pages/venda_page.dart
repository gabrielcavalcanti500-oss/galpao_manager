import 'package:flutter/material.dart';

import '../../../compras/data/materials_data.dart';
import '../../../compras/domain/entities/material_model.dart';
import '../../data/repositories/venda_repository.dart';
import '../../domain/entities/item_venda.dart';
import '../../domain/entities/venda.dart';

class VendaPage extends StatefulWidget {
  const VendaPage({super.key});

  @override
  State<VendaPage> createState() => _VendaPageState();
}

class _VendaPageState extends State<VendaPage> {
  MaterialModel? materialSelecionado;

  final TextEditingController quantidadeController = TextEditingController();

  final TextEditingController precoUnitarioController = TextEditingController();

  final List<ItemVenda> itens = [];

  final VendaRepository _vendaRepository = VendaRepository();

  int? indiceEditando;

  bool get materialPorUnidade =>
      materialSelecionado?.vendidoPorUnidade ?? false;

  double get quantidadeAtual {
    return double.tryParse(quantidadeController.text.replaceAll(',', '.')) ?? 0;
  }

  double get precoUnitarioAtual {
    return double.tryParse(precoUnitarioController.text.replaceAll(',', '.')) ??
        0;
  }

  double get subtotalAtual {
    return quantidadeAtual * precoUnitarioAtual;
  }

  double get totalVenda {
    return itens.fold(0, (total, item) => total + item.subtotal);
  }

  double get pesoTotal {
    return itens
        .where((item) => item.vendidoPorPeso)
        .fold(0, (total, item) => total + item.quantidade);
  }

  void selecionarMaterial(MaterialModel material) {
    setState(() {
      materialSelecionado = material;

      quantidadeController.clear();
      precoUnitarioController.clear();

      indiceEditando = null;
    });
  }

  void adicionarItem() {
    if (materialSelecionado == null) {
      _mostrarMensagem('Selecione um material.');
      return;
    }

    if (quantidadeAtual <= 0) {
      _mostrarMensagem(
        materialPorUnidade ? 'Informe a quantidade.' : 'Informe o peso.',
      );
      return;
    }

    if (precoUnitarioAtual <= 0) {
      _mostrarMensagem(
        materialPorUnidade
            ? 'Informe o preço por unidade.'
            : 'Informe o preço por kg.',
      );
      return;
    }

    final item = ItemVenda(
      material: materialSelecionado!,
      quantidade: quantidadeAtual,
      precoUnitario: precoUnitarioAtual,
    );

    setState(() {
      if (indiceEditando != null) {
        itens[indiceEditando!] = item;
        indiceEditando = null;
      } else {
        itens.add(item);
      }

      materialSelecionado = null;
      quantidadeController.clear();
      precoUnitarioController.clear();
    });
  }

  void editarItem(int index) {
    final item = itens[index];

    setState(() {
      indiceEditando = index;
      materialSelecionado = item.material;

      quantidadeController.text = item.quantidade.toString();

      precoUnitarioController.text = item.precoUnitario.toStringAsFixed(2);
    });

    _mostrarMensagem('Edite os dados e salve a alteração.');
  }

  void confirmarExclusao(int index) {
    final item = itens[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir item?'),
          content: Text('Deseja remover "${item.material.nome}" da venda?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext);
                removerItem(index);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void removerItem(int index) {
    setState(() {
      itens.removeAt(index);

      if (indiceEditando == index) {
        indiceEditando = null;
        materialSelecionado = null;
        quantidadeController.clear();
        precoUnitarioController.clear();
      } else if (indiceEditando != null && index < indiceEditando!) {
        indiceEditando = indiceEditando! - 1;
      }
    });
  }

  void cancelarEdicao() {
    setState(() {
      indiceEditando = null;
      materialSelecionado = null;
      quantidadeController.clear();
      precoUnitarioController.clear();
    });
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> finalizarVenda() async {
    if (itens.isEmpty) {
      _mostrarMensagem('Adicione pelo menos um item.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar venda'),
          content: Text(
            'Deseja finalizar esta venda no valor de '
            'R\$ ${totalVenda.toStringAsFixed(2)}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final venda = Venda(data: DateTime.now(), itens: List.unmodifiable(itens));

    try {
      final id = await _vendaRepository.salvarVenda(venda);

      if (!mounted) return;

      setState(() {
        itens.clear();
        materialSelecionado = null;
        quantidadeController.clear();
        precoUnitarioController.clear();
        indiceEditando = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venda #$id salva com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar venda: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    quantidadeController.dispose();
    precoUnitarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(title: const Text('Nova Venda'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                icon: Icons.inventory_2_rounded,
                title: 'Material',
                subtitle: 'Escolha o material da venda',
              ),

              const SizedBox(height: 12),

              _buildMaterialSelector(),

              const SizedBox(height: 24),

              if (materialSelecionado != null) ...[
                _buildSectionTitle(
                  icon: materialPorUnidade
                      ? Icons.inventory_2_rounded
                      : Icons.scale_rounded,
                  title: materialPorUnidade
                      ? 'Quantidade e preço'
                      : 'Peso e preço',
                  subtitle: materialPorUnidade
                      ? 'Informe quantidade e valor por unidade'
                      : 'Informe o peso e o preço por kg',
                ),

                const SizedBox(height: 12),

                _buildInputField(
                  controller: quantidadeController,
                  label: materialPorUnidade ? 'Quantidade' : 'Peso (kg)',
                  hintText: materialPorUnidade ? 'Ex.: 2' : 'Ex.: 15,5',
                  icon: materialPorUnidade
                      ? Icons.numbers_rounded
                      : Icons.scale_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 12),

                _buildInputField(
                  controller: precoUnitarioController,
                  label: materialPorUnidade
                      ? 'Preço por unidade'
                      : 'Preço por kg',
                  hintText: materialPorUnidade ? 'Ex.: 120,00' : 'Ex.: 42,00',
                  prefix: 'R\$ ',
                  icon: Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 16),

                _buildSubtotalCard(),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: adicionarItem,
                    icon: Icon(
                      indiceEditando == null
                          ? Icons.add_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      indiceEditando == null
                          ? 'Adicionar material'
                          : 'Salvar alteração',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                if (indiceEditando != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: cancelarEdicao,
                      child: const Text('Cancelar edição'),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 28),

              _buildSectionTitle(
                icon: Icons.sell_rounded,
                title: 'Itens da venda',
                subtitle: itens.isEmpty
                    ? 'Nenhum material adicionado'
                    : '${itens.length} '
                          '${itens.length == 1 ? 'item adicionado' : 'itens adicionados'}',
              ),

              const SizedBox(height: 12),

              if (itens.isEmpty) _buildEmptyState() else _buildListaItens(),

              const SizedBox(height: 20),

              _buildSummary(),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: itens.isEmpty ? null : finalizarVenda,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Finalizar Venda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MaterialModel>(
          value: materialSelecionado,
          isExpanded: true,
          hint: const Text('Selecione um material'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: materiais.map((material) {
            return DropdownMenuItem<MaterialModel>(
              value: material,
              child: Text(material.nome),
            );
          }).toList(),
          onChanged: (material) {
            if (material != null) {
              selecionarMaterial(material);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubtotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEAF7EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate_rounded, color: Color(0xff0B7A3E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  'R\$ ${subtotalAtual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0B7A3E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaItens() {
    return Column(
      children: List.generate(itens.length, (index) {
        final item = itens[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffEAF7EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xff0B7A3E),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.material.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.vendidoPorUnidade
                          ? '${item.quantidade.toStringAsFixed(0)} un × '
                                'R\$ ${item.precoUnitario.toStringAsFixed(2)}'
                          : '${item.quantidade.toStringAsFixed(2)} kg × '
                                'R\$ ${item.precoUnitario.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0B7A3E),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () => editarItem(index),
                icon: const Icon(Icons.edit_rounded),
              ),

              IconButton(
                onPressed: () => confirmarExclusao(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xffEAF7EF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xff0B7A3E), size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
    required ValueChanged<String> onChanged,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: prefix,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xff0B7A3E), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        children: [
          Icon(Icons.sell_outlined, size: 42, color: Colors.black26),
          SizedBox(height: 10),
          Text(
            'Nenhum item adicionado',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Selecione um material acima para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff0B7A3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: Colors.white70),
              SizedBox(width: 10),
              Text(
                'Resumo da venda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _summaryItem('Itens', itens.length.toString()),
              _summaryItem('Peso', '${pesoTotal.toStringAsFixed(2)} kg'),
              _summaryItem('Total', 'R\$ ${totalVenda.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
