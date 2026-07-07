import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:totales_flutter/app_state.dart';
import 'package:totales_flutter/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pestaña Inicio', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TotalesState(),
        child: const TotalesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
  });
}
