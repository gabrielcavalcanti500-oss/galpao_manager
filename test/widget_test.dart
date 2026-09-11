import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galpao_manager/app/app.dart';

void main() {
  testWidgets('Aplicativo inicia corretamente', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GalpaoManagerApp()));

    expect(find.text('Galpão Manager'), findsOneWidget);
  });
}
