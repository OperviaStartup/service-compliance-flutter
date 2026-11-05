import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_compliance/features/about_product/presentation/about_product_page.dart';

void main() {
  testWidgets('muestra las secciones del primer corte', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: AboutProductPage()));

    expect(find.text('Acerca del producto'), findsOneWidget);
    expect(find.text('El problema'), findsOneWidget);
    expect(find.text('Usuarios'), findsOneWidget);
    expect(find.text('La solución'), findsOneWidget);
    expect(find.text('Demo: lo que ya se ve en la app'), findsOneWidget);
    expect(find.text('Estado actual'), findsOneWidget);
  });
}
