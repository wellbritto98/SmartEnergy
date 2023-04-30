import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_energy/main.dart'; // Substitua 'my_app' pelo nome do seu projeto
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


void main() {
  testWidgets('Teste de inicialização do aplicativo', (WidgetTester tester) async {
    // Cria o widget MyApp e adiciona ao widget tree
    await tester.pumpWidget(MyApp());

    // Verifica se o título da AppBar é "Medição de energia"
    expect(find.text('Medição de energia'), findsOneWidget);

    // Verifica se o ícone de "Medição" está presente na BottomNavigationBar
    expect(find.byIcon(FontAwesomeIcons.bolt), findsOneWidget);

    // Verifica se o ícone de "Eletrodomésticos" está presente na BottomNavigationBar
    expect(find.byIcon(FontAwesomeIcons.plug), findsOneWidget);

    // Verifica se o ícone de "Relatórios" está presente na BottomNavigationBar
    expect(find.byIcon(FontAwesomeIcons.chartBar), findsOneWidget);
  });
}
