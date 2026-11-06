import 'package:flutter_test/flutter_test.dart';
import 'package:service_compliance/app/app.dart';

void main() {
  testWidgets('navega entre los módulos iniciales', (tester) async {
    await tester.pumpWidget(const OperviaApp());
    expect(find.text('Consulta de obligaciones operativas.'), findsOneWidget);
    await tester.tap(find.text('Incidencias').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('DATOS DE MUESTRA'), findsOneWidget);
    await tester.tap(find.text('Cuenta').last);
    await tester.pumpAndSettle();
    expect(find.text('Acceso y perfil de usuario.'), findsOneWidget);
  });
}
