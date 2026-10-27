import 'package:flutter/material.dart';

import '../../data/repositories/compra_repository.dart';
import '../../domain/entities/compra.dart';
import '../../domain/entities/item_compra.dart';
import '../../domain/entities/material_model.dart';
import '../widgets/lista_itens.dart';
import '../widgets/material_selector.dart';
import '../widgets/subtotal_card.dart';

class ComprasPage extends StatefulWidget {
  const ComprasPage({super.key});

  @override
  State<ComprasPage> createState() => _ComprasPageState();
}

class _ComprasPageState extends State<ComprasPage> {
  MaterialModel? materialSelecionado;

  final TextEditingController quantidadeController = TextEditingController();

  final TextEditingController precoUnitarioController = TextEditingController();

  final List<ItemCompra> itens = [];

  final CompraRepository _compraRepository = CompraRepository();

  // Guarda o índice do item que está sendo editado.
  // null = estamos adicionando um novo item.
  int? indiceEditando;

  bool get materialPorUnidade =>
      materialSelecionado?.vendidoPorUnidade ?? false;

  double get quantidadeAtual {
    return double.tryParse(quantidadeController.text.replaceAll(',', '.')) ?? 0;
  }

  double get precoUnitarioAtual {
    if (materialSelecionado == null) return 0;

    // Motor / materiais vendidos por unidade
    if (materialPorUnidade) {
      return double.tryParse(
            precoUnitarioController.text.replaceAll(',', '.'),
          ) ??
          0;
    }

    // Materiais vendidos por kg
    return materialSelecionado!.precoPadrao ?? 0;
  }

  double get subtotalAtual {
    return quantidadeAtual * precoUnitarioAtual;
  }

  double get totalCompra {
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

    if (materialPorUnidade && precoUnitarioAtual <= 0) {
      _mostrarMensagem('Informe o preço por unidade.');
      return;
    }

    final item = ItemCompra(
      material: materialSelecionado!,
      quantidade: quantidadeAtual,
      precoUnitario: precoUnitarioAtual,
    );

    setState(() {
      if (indiceEditando != null) {
        // Atualiza o item existente.
        itens[indiceEditando!] = item;
        indiceEditando = null;
      } else {
        // Adiciona um novo item.
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

      if (item.vendidoPorUnidade) {
        precoUnitarioController.text = item.precoUnitario.toStringAsFixed(2);
      } else {
        precoUnitarioController.clear();
      }
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
          content: Text('Deseja remover "${item.material.nome}" da compra?'),
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

      // Se estávamos editando esse item, cancelamos a edição.
      if (indiceEditando == index) {
        indiceEditando = null;
        materialSelecionado = null;
        quantidadeController.clear();
        precoUnitarioController.clear();
      }
      // Se removemos um item antes do item que está sendo editado,
      // precisamos ajustar o índice.
      else if (indiceEditando != null && index < indiceEditando!) {
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

  Future<void> finalizarCompra() async {
    if (itens.isEmpty) {
      _mostrarMensagem('Adicione pelo menos um item.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar compra'),
          content: Text(
            'Deseja finalizar esta compra no valor de '
            'R\$ ${totalCompra.toStringAsFixed(2)}?',
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

    final compra = Compra(
      data: DateTime.now(),
      itens: List.unmodifiable(itens),
    );

    try {
      final id = await _compraRepository.salvarCompra(compra);

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
          content: Text('Compra #$id salva com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar compra: $e'),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF172B4D),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nova compra',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2),
            Text(
              'Registre os materiais recebidos',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFD5DEEB),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                icon: Icons.inventory_2_rounded,
                title: 'Material',
                subtitle: 'Escolha o material da compra',
              ),

              const SizedBox(height: 12),

              MaterialSelector(
                materialSelecionado: materialSelecionado,
                onSelected: selecionarMaterial,
              ),

              const SizedBox(height: 24),

              if (materialSelecionado != null) ...[
                _buildSectionTitle(
                  icon: materialPorUnidade
                      ? Icons.inventory_2_rounded
                      : Icons.scale_rounded,
                  title: materialPorUnidade ? 'Quantidade e preço' : 'Peso',
                  subtitle: materialPorUnidade
                      ? 'Informe quantidade e valor por unidade'
                      : 'Informe o peso do material',
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

                if (materialPorUnidade) ...[
                  const SizedBox(height: 12),

                  _buildInputField(
                    controller: precoUnitarioController,
                    label: 'Preço por unidade',
                    hintText: 'Ex.: 120,00',
                    prefix: 'R\$ ',
                    icon: Icons.attach_money_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],

                if (!materialPorUnidade &&
                    materialSelecionado!.precoPadrao != null) ...[
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6EF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBEBDD)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.sell_rounded,
                            color: Color(0xFF16865B),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preço por quilograma',
                                style: TextStyle(
                                  color: Color(0xFF527463),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Valor padrão do material',
                                style: TextStyle(
                                  color: Color(0xFF16865B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${materialSelecionado!.precoPadrao!.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: Color(0xFF16865B),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                SubtotalCard(subtotal: subtotalAtual),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: adicionarItem,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16865B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      indiceEditando == null
                          ? Icons.add_circle_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 22,
                    ),
                    label: Text(
                      indiceEditando == null
                          ? 'Adicionar material'
                          : 'Salvar alteração',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Aparece somente durante uma edição.
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
                icon: Icons.shopping_cart_rounded,
                title: 'Itens da compra',
                subtitle: itens.isEmpty
                    ? 'Nenhum material adicionado'
                    : '${itens.length} '
                          '${itens.length == 1 ? 'item adicionado' : 'itens adicionados'}',
              ),

              const SizedBox(height: 12),

              if (itens.isEmpty)
                _buildEmptyState()
              else
                ListaItens(
                  itens: itens,
                  onEdit: editarItem,
                  onDelete: confirmarExclusao,
                ),

              const SizedBox(height: 20),

              _buildSummary(),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: itens.isEmpty ? null : finalizarCompra,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF172B4D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE3E8EF),
                    disabledForegroundColor: const Color(0xFF9AA6B5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: const Text(
                    'Finalizar Compra',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6EF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF16865B), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172B4D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
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
          Icon(Icons.shopping_cart_outlined, size: 42, color: Colors.black26),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF172B4D), Color(0xFF243F65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172B4D).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF70D9AA),
                size: 23,
              ),
              SizedBox(width: 10),
              Text(
                'Resumo da compra',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'VALOR TOTAL',
            style: TextStyle(
              color: Color(0xFFCCD7E5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'R\$ ${totalCompra.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 18),
          Row(
            children: [
              _summaryItem(
                Icons.inventory_2_outlined,
                'Itens',
                itens.length.toString(),
              ),
              const SizedBox(width: 12),
              _summaryItem(
                Icons.scale_outlined,
                'Peso total',
                '${pesoTotal.toStringAsFixed(2).replaceAll('.', ',')} kg',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 19, color: const Color(0xFF70D9AA)),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Color(0xFFCCD7E5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
