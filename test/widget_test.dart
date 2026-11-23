import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_compliance/app/app.dart';
import 'package:service_compliance/app/opervia_backdrop.dart';

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

  testWidgets(
    'mantiene el mismo fondo en las pestañas y rutas de incidencias',
    (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const OperviaApp());
      final backdrop = tester.element(find.byType(OperviaBackdrop));

      void expectSharedBackdrop() {
        expect(tester.element(find.byType(OperviaBackdrop)), same(backdrop));
        final context = tester.element(find.byType(Scaffold).last);
        expect(Theme.of(context).scaffoldBackgroundColor, Colors.transparent);
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
          isNull,
        );
      }

      expectSharedBackdrop();
      for (final tab in ['Cumplimiento', 'Cuenta', 'Incidencias']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        expectSharedBackdrop();
      }

      await tester.tap(find.byTooltip('Acerca del producto'));
      await tester.pumpAndSettle();
      expect(find.text('Acerca del producto'), findsOneWidget);
      expectSharedBackdrop();
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reportar impedimento o incidencia'));
      await tester.pumpAndSettle();
      expect(find.text('Reportar Impedimento'), findsOneWidget);
      expectSharedBackdrop();

      await tester.tap(find.text('Faltan insumos'));
      final send = find.text('ENVIAR PARA REVISIÓN');
      await tester.scrollUntilVisible(
        send,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(find.text('Impedimento registrado'), findsOneWidget);
      expectSharedBackdrop();
    },
  );
}
