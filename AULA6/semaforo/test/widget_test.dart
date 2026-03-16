import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:semaforo/main.dart';

void main() {
  testWidgets('Teste de abertura do app', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(
      home: SemaforoApp(),
    ));

    expect(find.text('Semáforo de Trânsito'), findsOneWidget);

  });
}