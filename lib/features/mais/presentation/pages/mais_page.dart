import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  static const Color _navy = Color(0xFF172B4D);
  static const Color _background = Color(0xFFF4F6FA);
  static const Color _muted = Color(0xFF7D899B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _cabecalho(),
            const SizedBox(height: 26),

            const _TituloSecao(
              titulo: 'Operações',
              descricao: 'Gerencie as atividades do seu galpão',
            ),
            const SizedBox(height: 14),

            _CardOperacao(
              icone: Icons.shopping_cart_rounded,
              titulo: 'Nova compra',
              descricao: 'Registrar entrada de materiais',
              cor: const Color(0xFF16865B),
              rota: '/compras',
            ),
            _CardOperacao(
              icone: Icons.sell_rounded,
              titulo: 'Nova venda',
              descricao: 'Registrar venda de materiais',
              cor: const Color(0xFF3468D4),
              rota: '/vendas',
            ),
            _CardOperacao(
              icone: Icons.account_balance_wallet_rounded,
              titulo: 'Novo gasto',
              descricao: 'Registrar despesas do galpão',
              cor: const Color(0xFFDF8A32),
              rota: '/gastos',
            ),
            _CardOperacao(
              icone: Icons.inventory_2_rounded,
              titulo: 'Retirada de material',
              descricao: 'Registrar saída do estoque',
              cor: const Color(0xFF8757D8),
              rota: '/retiradas',
            ),

            const SizedBox(height: 28),

            const _TituloSecao(
              titulo: 'Históricos',
              descricao: 'Consulte suas movimentações anteriores',
            ),
            const SizedBox(height: 14),

            _CardHistorico(
              icone: Icons.shopping_bag_outlined,
              titulo: 'Compras',
              descricao: 'Consulte as compras registradas',
              rota: '/historico-compras',
            ),
            _CardHistorico(
              icone: Icons.receipt_long_outlined,
              titulo: 'Vendas',
              descricao: 'Consulte as vendas registradas',
              rota: '/historico-vendas',
            ),
            _CardHistorico(
              icone: Icons.request_quote_outlined,
              titulo: 'Gastos',
              descricao: 'Consulte as despesas registradas',
              rota: '/historico-gastos',
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF172B4D), Color(0xFF205B56)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco_rounded, color: Color(0xFF7CE5AD), size: 30),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Galpão Manager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Organização e controle para o seu negócio.',
                          style: TextStyle(
                            color: Color(0xFFD8E5E8),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: _navy.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.grid_view_rounded, color: _navy, size: 27),
        ),
        const SizedBox(height: 18),
        const Text(
          'Tudo em um só lugar',
          style: TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Mais opções',
          style: TextStyle(
            color: _navy,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Acesse as operações e consulte os históricos do galpão.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }
}

class _TituloSecao extends StatelessWidget {
  final String titulo;
  final String descricao;

  const _TituloSecao({required this.titulo, required this.descricao});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          descricao,
          style: const TextStyle(color: Color(0xFF7D899B), fontSize: 12),
        ),
      ],
    );
  }
}

class _CardOperacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Color cor;
  final String rota;

  const _CardOperacao({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.cor,
    required this.rota,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EDF4)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(rota),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icone, color: cor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Color(0xFF172B4D),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        descricao,
                        style: const TextStyle(
                          color: Color(0xFF7D899B),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFF9AA5B5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHistorico extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final String rota;

  const _CardHistorico({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.rota,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF4)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(rota),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF3FA),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icone, color: const Color(0xFF172B4D), size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Color(0xFF172B4D),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descricao,
                        style: const TextStyle(
                          color: Color(0xFF7D899B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9AA5B5),
                  size: 23,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
