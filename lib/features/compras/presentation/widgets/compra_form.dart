import 'package:flutter/material.dart';

class CompraForm extends StatefulWidget {
  const CompraForm({super.key});

  @override
  State<CompraForm> createState() => _CompraFormState();
}

class _CompraFormState extends State<CompraForm> {
  final vendedorController = TextEditingController();

  final pesoController = TextEditingController();

  final valorKgController = TextEditingController();

  final observacaoController = TextEditingController();

  String material = "Ferro";

  double total = 0;

  final materiais = [
    "Ferro",
    "Alumínio",
    "Cobre",
    "Metal",
    "Plástico",
    "Papelão",
  ];

  void calcularTotal() {
    final peso = double.tryParse(pesoController.text.replaceAll(",", ".")) ?? 0;

    final valor =
        double.tryParse(valorKgController.text.replaceAll(",", ".")) ?? 0;

    setState(() {
      total = peso * valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: vendedorController,
          decoration: const InputDecoration(
            labelText: "Vendedor",
            prefixIcon: Icon(Icons.person),
          ),
        ),

        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: material,
          decoration: const InputDecoration(
            labelText: "Material",
            prefixIcon: Icon(Icons.inventory),
          ),
          items: materiais
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() {
              material = v!;
            });
          },
        ),

        const SizedBox(height: 16),

        TextField(
          controller: pesoController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Peso (kg)",
            prefixIcon: Icon(Icons.scale),
          ),
          onChanged: (_) => calcularTotal(),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: valorKgController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Valor por Kg",
            prefixIcon: Icon(Icons.attach_money),
          ),
          onChanged: (_) => calcularTotal(),
        ),

        const SizedBox(height: 24),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text("Total"),
            subtitle: Text("R\$ ${total.toStringAsFixed(2)}"),
          ),
        ),

        const SizedBox(height: 24),

        TextField(
          controller: observacaoController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Observação",
            prefixIcon: Icon(Icons.notes),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Compra salva! (temporário)")),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text("Salvar Compra"),
          ),
        ),
      ],
    );
  }
}
