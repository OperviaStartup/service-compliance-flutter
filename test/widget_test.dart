import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:service_compliance/app/app.dart';
import 'package:service_compliance/app/opervia_backdrop.dart';
import 'package:service_compliance/core/network/api_client.dart';

Future<void> signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'test@example.test');
  await tester.enterText(find.byType(TextFormField).at(1), 'sample-password');
  await tester.tap(find.text('Ingresar'));
  await tester.pumpAndSettle();
}

http.Response session(String role) => http.Response(
  jsonEncode({
    'token': 'test-access',
    'refreshToken': 'test-refresh',
    'fullName': 'Usuario de prueba',
    'email': 'test@example.test',
    'role': role,
  }),
  200,
);

void main() {
  testWidgets('supervisa obligaciones y revisa una ejecución enviada', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final api = ApiClient(
      baseUrl: 'https://example.test',
      client: MockClient((request) async {
        requests.add(request);
        switch (request.url.path) {
          case '/api/v1/auth/login':
            return session('SUPERVISOR');
          case '/api/v1/operational-obligations':
            return http.Response(
              jsonEncode({
                'items': [
                  {
                    'obligationId': 5,
                    'activity': 'Limpieza de aulas',
                    'siteName': 'Sede de prueba',
                    'operatorName': 'Operario de prueba',
                    'dueAt': '2026-11-26T15:00:00Z',
                    'status': 'SUBMITTED',
                  },
                ],
                'counts': {'SUBMITTED': 1},
                'total': 1,
                'nextCursor': null,
              }),
              200,
            );
          case '/api/v1/obligations/5/execution':
            return http.Response('{"id":12}', 200);
          case '/api/v1/compliance-reviews/executions/12':
            return http.Response(
              jsonEncode({
                'obligation': {'title': 'Limpieza de aulas'},
                'execution': {'result': 'PARTIAL'},
                'evidence': [],
                'exceptions': [],
                'missingInformation': [
                  {
                    'category': 'EVIDENCE',
                    'code': 'MISSING',
                    'actualCount': 0,
                    'expectedCount': 1,
                  },
                ],
              }),
              200,
            );
          case '/api/v1/auth/logout':
            return http.Response('', 204);
          default:
            return http.Response('', 404);
        }
      }),
    );
    addTearDown(api.close);

    await tester.pumpWidget(OperviaApp(api: api));
    final backdrop = tester.element(find.byType(OperviaBackdrop));
    await signIn(tester);
    expect(find.text('Resumen operativo'), findsOneWidget);
    expect(find.text('1 obligación'), findsOneWidget);

    final navigationIcon = tester.element(
      find.byIcon(Icons.space_dashboard_outlined),
    );
    expect(IconTheme.of(navigationIcon).size, 32);

    for (final tab in ['Reportes', 'Actividades', 'Casos']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(OperviaBackdrop)), same(backdrop));
    }
    expect(requests.last.url.queryParameters['status'], 'SUBMITTED,EXCEPTED');

    await tester.tap(find.text('Limpieza de aulas'));
    await tester.pumpAndSettle();
    expect(find.text('Revisar ejecución'), findsOneWidget);
    expect(find.text('Información faltante'), findsOneWidget);
    expect(tester.element(find.byType(OperviaBackdrop)), same(backdrop));

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(jsonDecode(requests.first.body), {
      'identifier': 'test@example.test',
      'password': 'sample-password',
    });
    expect(jsonDecode(requests.last.body), {'refreshToken': 'test-refresh'});
    expect(
      requests
          .where((request) => request.method == 'GET')
          .every(
            (request) =>
                request.headers['authorization'] == 'Bearer test-access',
          ),
      isTrue,
    );
  });

  testWidgets('un operario no puede abrir el área de supervisión', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final api = ApiClient(
      baseUrl: 'https://example.test',
      client: MockClient((request) async {
        requests.add(request);
        return session('OPERATOR');
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(OperviaApp(api: api));
    await signIn(tester);

    expect(requests, hasLength(1));
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.textContaining('aplicación de operarios'), findsOneWidget);
  });

  testWidgets('mantiene el mismo fondo en la demo y las rutas de incidencias', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const OperviaApp());
    final backdrop = tester.element(find.byType(OperviaBackdrop));

    void expectSharedBackdrop() {
      expect(tester.element(find.byType(OperviaBackdrop)), same(backdrop));
      final scaffold = find.byType(Scaffold).last;
      final context = tester.element(scaffold);
      expect(tester.getTopLeft(scaffold).dy, 40);
      expect(Theme.of(context).scaffoldBackgroundColor, Colors.transparent);
      expect(tester.widget<Scaffold>(scaffold).backgroundColor, isNull);
    }

    expectSharedBackdrop();
    await tester.tap(find.text('Ver demostración de incidencias'));
    await tester.pumpAndSettle();
    expect(find.textContaining('DATOS DE MUESTRA'), findsOneWidget);
    expectSharedBackdrop();

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
      send.hitTestable(),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.text('Simulación de reporte'), findsOneWidget);
    expectSharedBackdrop();
  });
}
