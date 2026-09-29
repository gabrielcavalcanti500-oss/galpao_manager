import 'package:flutter/material.dart';

import 'gm_bottom_navbar.dart';

class GmNavigationShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;

  const GmNavigationShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavigationChanged,
  });

  @override
  State<GmNavigationShell> createState() => _GmNavigationShellState();
}

class _GmNavigationShellState extends State<GmNavigationShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: GmBottomNavbar(
        currentIndex: widget.currentIndex,
        onTap: widget.onNavigationChanged,
      ),
    );
  }
}
