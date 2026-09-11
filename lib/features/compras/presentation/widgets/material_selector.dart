import 'package:flutter/material.dart';

import '../../data/materials_data.dart';
import '../../domain/entities/material_model.dart';

class MaterialSelector extends StatelessWidget {
  final MaterialModel? materialSelecionado;
  final ValueChanged<MaterialModel> onSelected;

  const MaterialSelector({
    super.key,
    required this.materialSelecionado,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final material = await showModalBottomSheet<MaterialModel>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          backgroundColor: Colors.white,
          builder: (_) => const _MaterialPicker(),
        );

        if (material != null) {
          onSelected(material);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: materialSelecionado == null
                ? Colors.grey.shade300
                : const Color(0xff0B7A3E),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xffEAF7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                materialSelecionado?.vendidoPorUnidade == true
                    ? Icons.inventory_2_rounded
                    : Icons.scale_rounded,
                color: const Color(0xff0B7A3E),
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    materialSelecionado?.nome ?? 'Selecionar material',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: materialSelecionado == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),

                  if (materialSelecionado != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      materialSelecionado!.vendidoPorUnidade
                          ? 'Vendido por unidade'
                          : 'Vendido por kg',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialPicker extends StatefulWidget {
  const _MaterialPicker();

  @override
  State<_MaterialPicker> createState() => _MaterialPickerState();
}

class _MaterialPickerState extends State<_MaterialPicker> {
  String pesquisa = '';

  @override
  Widget build(BuildContext context) {
    final lista = materiais.where((material) {
      return material.nome.toLowerCase().contains(pesquisa.toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Pesquisar material...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: const Color(0xffF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  pesquisa = value;
                });
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: lista.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum material encontrado.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, index) {
                        final material = lista[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xffEAF7EF),
                            child: Icon(
                              material.vendidoPorUnidade
                                  ? Icons.inventory_2_rounded
                                  : Icons.scale_rounded,
                              color: const Color(0xff0B7A3E),
                            ),
                          ),
                          title: Text(
                            material.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            material.vendidoPorUnidade
                                ? 'Vendido por unidade'
                                : material.precoPadrao != null
                                ? 'R\$ ${material.precoPadrao!.toStringAsFixed(2)}/kg'
                                : 'Vendido por kg',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.pop(context, material);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
