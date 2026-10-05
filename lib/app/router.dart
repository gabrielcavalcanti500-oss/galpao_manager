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
            builder: (context, state) {
              return const Scaffold(body: Center(child: Text('Mais')));
            },
          ),
        ],
      ),

      GoRoute(
        path: '/compras',
        builder: (context, state) => const ComprasPage(),
      ),

      GoRoute(path: '/gastos', builder: (context, state) => const GastoPage()),

      GoRoute(
        path: '/historico-gastos',
        builder: (context, state) => const HistoricoGastosPage(),
      ),

      GoRoute(path: '/vendas', builder: (context, state) => const VendaPage()),

      GoRoute(
        path: '/historico-vendas',
        builder: (context, state) => const HistoricoVendasPage(),
      ),

      GoRoute(
        path: '/historico-compras',
        builder: (context, state) => const HistoricoComprasPage(),
      ),
    ],
  );

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
