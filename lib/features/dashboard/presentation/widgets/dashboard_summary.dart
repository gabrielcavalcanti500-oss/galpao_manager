import 'package:flutter/material.dart';

import '../../../../shared/widgets/gm_info_card.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        GMInfoCard(
          titulo: "Compras Hoje",
          valor: "R\$ 0,00",
          icone: Icons.shopping_cart,
          cor: Colors.green,
        ),

        SizedBox(height: 16),

        GMInfoCard(
          titulo: "Vendas Hoje",
          valor: "R\$ 0,00",
          icone: Icons.sell,
          cor: Colors.blue,
        ),

        SizedBox(height: 16),

        GMInfoCard(
          titulo: "Gastos",
          valor: "R\$ 0,00",
          icone: Icons.money_off,
          cor: Colors.red,
        ),

        SizedBox(height: 16),

        GMInfoCard(
          titulo: "Resultado",
          valor: "R\$ 0,00",
          icone: Icons.trending_up,
          cor: Colors.orange,
        ),
      ],
    );
  }
}
