import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/compras/presentation/pages/compra_page.dart';
import '../features/compras/presentation/pages/historico_compras_page.dart';
import '../features/gastos/presentation/pages/gasto_page.dart';
import '../features/gastos/presentation/pages/historico_gastos_page.dart';
import '../features/vendas/presentation/pages/venda_page.dart';
import '../features/vendas/presentation/pages/historico_vendas_page.dart';
import '../features/estoque/presentation/pages/estoque_page.dart';
import '../features/relatorios/presentation/pages/relatorios_page.dart';
import '../features/retiradas/presentation/pages/retirada_page.dart';
import '../shared/components/navigation/gm_bottom_navbar.dart';

final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: GmBottomNavbar(
              currentIndex: _indiceAtual(state.uri.path),
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/relatorios');
                    break;
                  case 2:
                    context.go('/estoque');
                    break;
                  case 3:
                    context.go('/mais');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/relatorios',
            builder: (context, state) => const RelatoriosPage(),
          ),
          GoRoute(
            path: '/estoque',
            builder: (context, state) => const EstoquePage(),
          ),
          GoRoute(
            path: '/mais',
            builder: (context, state) => _paginaMais(context),
          ),
          GoRoute(
            path: '/compras',
            builder: (context, state) => const ComprasPage(),
          ),
          GoRoute(
            path: '/gastos',
            builder: (context, state) => const GastoPage(),
          ),
          GoRoute(
            path: '/historico-gastos',
            builder: (context, state) => const HistoricoGastosPage(),
          ),
          GoRoute(
            path: '/vendas',
            builder: (context, state) => const VendaPage(),
          ),
          GoRoute(
            path: '/retiradas',
            builder: (context, state) => const RetiradaPage(),
          ),
          GoRoute(
            path: '/historico-vendas',
            builder: (context, state) => const HistoricoVendasPage(),
          ),
          GoRoute(
            path: '/historico-compras',
            builder: (context, state) => const HistoricoComprasPage(),
          ),
        ],
      ),
    ],
  );

  static Widget _paginaMais(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mais opções')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(
              'Acesse as funcionalidades do galpão',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),

          _tituloSecao('Operações'),

          _itemMais(
            icone: Icons.shopping_cart_outlined,
            titulo: 'Nova compra',
            descricao: 'Registrar entrada de materiais',
            aoTocar: () => context.push('/compras'),
          ),

          _itemMais(
            icone: Icons.sell_outlined,
            titulo: 'Nova venda',
            descricao: 'Registrar venda de materiais',
            aoTocar: () => context.push('/vendas'),
          ),

          _itemMais(
            icone: Icons.account_balance_wallet_outlined,
            titulo: 'Novo gasto',
            descricao: 'Registrar despesas do galpão',
            aoTocar: () => context.push('/gastos'),
          ),

          _itemMais(
            icone: Icons.inventory_2_outlined,
            titulo: 'Retirada de material',
            descricao: 'Registrar saída de materiais do estoque',
            aoTocar: () => context.push('/retiradas'),
          ),

          const SizedBox(height: 20),

          _tituloSecao('Históricos'),

          _itemMais(
            icone: Icons.shopping_bag_outlined,
            titulo: 'Histórico de compras',
            descricao: 'Consultar compras registradas',
            aoTocar: () => context.push('/historico-compras'),
          ),

          _itemMais(
            icone: Icons.receipt_long_outlined,
            titulo: 'Histórico de vendas',
            descricao: 'Consultar vendas registradas',
            aoTocar: () => context.push('/historico-vendas'),
          ),

          _itemMais(
            icone: Icons.request_quote_outlined,
            titulo: 'Histórico de gastos',
            descricao: 'Consultar despesas registradas',
            aoTocar: () => context.push('/historico-gastos'),
          ),
        ],
      ),
    );
  }

  static Widget _tituloSecao(String titulo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0B2545),
        ),
      ),
    );
  }

  static Widget _itemMais({
    required IconData icone,
    required String titulo,
    required String descricao,
    required VoidCallback aoTocar,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: const Color(0xFF0B2545)),
          ),
          title: Text(
            titulo,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            descricao,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black45),
          onTap: aoTocar,
        ),
        const Divider(height: 1, indent: 60, endIndent: 8),
      ],
    );
  }

  static int _indiceAtual(String path) {
    if (path == '/relatorios') {
      return 1;
    }

    if (path == '/estoque') {
      return 2;
    }

    if (path == '/mais') {
      return 3;
    }

    return 0;
  }
}
