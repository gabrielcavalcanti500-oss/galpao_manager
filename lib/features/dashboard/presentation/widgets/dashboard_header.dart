import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _capitalize(
      DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(now),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102846), Color(0xFF17466A), Color(0xFF176747)],
          stops: [0, 0.62, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102846).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Icon(
              Icons.recycling_rounded,
              size: 142,
              color: Colors.white.withValues(alpha: 0.055),
            ),
          ),
          Positioned(
            right: 5,
            bottom: -28,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                  width: 18,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.recycling_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GALPÃO MANAGER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Gestão do seu negócio',
                          style: TextStyle(
                            color: Color(0xFFCAD8E5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF6EE7A0), size: 8),
                        SizedBox(width: 6),
                        Text(
                          'Painel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                '${_greeting()} 👋',
                style: const TextStyle(
                  color: Color(0xFFD2E0EB),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Visão geral do galpão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: Color(0xFFB9CCDC),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    today,
                    style: const TextStyle(
                      color: Color(0xFFB9CCDC),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
