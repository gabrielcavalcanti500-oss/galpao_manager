import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/compras/presentation/pages/compra_page.dart';
import '../features/compras/presentation/pages/historico_compras_page.dart';
import '../features/gastos/presentation/pages/gasto_page.dart';
import '../features/gastos/presentation/pages/historico_gastos_page.dart';

final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),

      GoRoute(
        path: '/compras',
        builder: (context, state) => const ComprasPage(),
      ),

      GoRoute(path: '/gastos', builder: (context, state) => const GastoPage()),

      GoRoute(
        path: '/historico-gastos',
        builder: (context, state) => const HistoricoGastosPage(),
      ),

      GoRoute(
        path: '/historico-compras',
        builder: (context, state) => const HistoricoComprasPage(),
      ),
    ],
  );
}
