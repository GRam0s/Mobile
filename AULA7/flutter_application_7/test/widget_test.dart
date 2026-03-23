import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_7/main.dart';

void main() {
  testWidgets('Tela inicial exibe botão de navegação', (WidgetTester tester) async {
    // Constrói o app
    await tester.pumpWidget(MaterialApp(home: TelaInicio()));

    // Verifica se o texto do botão aparece na tela
    expect(find.text('Ir para a segunda tela'), findsOneWidget);

    // Verifica se o AppBar tem o título correto
    expect(find.text('Tela inicial'), findsOneWidget);
  });
}