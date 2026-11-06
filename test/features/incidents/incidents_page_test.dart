import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_compliance/core/network/api_client.dart';
import 'package:service_compliance/features/incidents/data/impediment.dart';
import 'package:service_compliance/features/incidents/data/incidents_repository.dart';
import 'package:service_compliance/features/incidents/presentation/incidents_page.dart';

const _task = ActiveTask(
  id: 'test-1',
  name: 'Tarea de prueba',
  building: 'Edificio de prueba',
  location: 'Sala de prueba',
  schedule: '10:00 - 10:30',
  startedAt: '10:04',
);

class _FakeRepository extends IncidentsRepository {
  _FakeRepository({this.onFetch, this.onSubmit});

  final Future<ActiveTask?> Function()? onFetch;
  final Future<ImpedimentRecord> Function(ImpedimentReport report)? onSubmit;
  ImpedimentReport? lastReport;

  @override
  Future<ActiveTask?> fetchActiveTask() async =>
      onFetch == null ? _task : onFetch!();

  @override
  Future<ImpedimentRecord> submitImpediment(ImpedimentReport report) async {
    lastReport = report;
    if (onSubmit != null) return onSubmit!(report);
    return ImpedimentRecord(
      report: report,
      sentAt: DateTime(2026, 11, 4, 10, 15),
    );
  }
}

Future<void> _pumpPage(WidgetTester tester, IncidentsRepository repository) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: IncidentsPage(repository: repository)),
    ),
  );
}

void main() {
  group('IncidentsPage', () {
    testWidgets('muestra carga y luego la actividad en curso', (tester) async {
      final completer = Completer<ActiveTask?>();
      await _pumpPage(tester, _FakeRepository(onFetch: () => completer.future));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(_task);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Tarea de prueba'), findsOneWidget);
      expect(find.text('Reportar impedimento o incidencia'), findsOneWidget);
    });

    testWidgets('muestra el estado vacío sin actividad en curso', (
      tester,
    ) async {
      await _pumpPage(tester, _FakeRepository(onFetch: () async => null));
      await tester.pumpAndSettle();

      expect(find.text('No tienes una actividad en curso.'), findsOneWidget);
    });

    testWidgets('muestra error y permite reintentar', (tester) async {
      var calls = 0;
      await _pumpPage(
        tester,
        _FakeRepository(
          onFetch: () async {
            calls++;
            if (calls == 1) throw const ApiException('Fallo de prueba.');
            return _task;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fallo de prueba.'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(find.text('Tarea de prueba'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('rotula los datos de muestra', (tester) async {
      await _pumpPage(
        tester,
        const SampleIncidentsRepository(delay: Duration.zero),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('DATOS DE MUESTRA'), findsOneWidget);
      expect(find.text('Limpieza de recepción'), findsOneWidget);
    });

    testWidgets('reporta un impedimento y muestra el registro', (tester) async {
      final repository = _FakeRepository();
      await _pumpPage(tester, repository);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reportar impedimento o incidencia'));
      await tester.pumpAndSettle();

      expect(find.text('Selecciona el motivo principal:'), findsOneWidget);

      await tester.tap(find.text('Faltan insumos'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Sin jabón');
      await tester.tap(find.text('ENVIAR PARA REVISIÓN'));
      await tester.pumpAndSettle();

      expect(repository.lastReport?.reason, ImpedimentReason.missingSupplies);
      expect(repository.lastReport?.detail, 'Sin jabón');
      expect(find.text('Impedimento registrado'), findsOneWidget);
      expect(find.text('Enviado hoy, 10:15'), findsOneWidget);
      expect(find.text('Turno protegido'), findsOneWidget);

      await tester.tap(find.text('VOLVER A MIS TAREAS'));
      await tester.pumpAndSettle();

      expect(find.text('Reportar impedimento o incidencia'), findsOneWidget);
    });

    testWidgets('muestra error al enviar y se queda en el formulario', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        _FakeRepository(
          onSubmit: (_) async => throw const ApiException('Envío fallido.'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reportar impedimento o incidencia'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ENVIAR PARA REVISIÓN'));
      await tester.pumpAndSettle();

      expect(find.text('Envío fallido.'), findsOneWidget);
      expect(find.text('Impedimento registrado'), findsNothing);
      expect(find.text('ENVIAR PARA REVISIÓN'), findsOneWidget);
    });

    testWidgets('abre About Product desde el botón de información', (
      tester,
    ) async {
      await _pumpPage(tester, _FakeRepository());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Acerca del producto'));
      await tester.pumpAndSettle();

      expect(find.text('El problema'), findsOneWidget);
    });
  });

  group('SampleIncidentsRepository', () {
    test('sin actividad devuelve null', () async {
      const repo = SampleIncidentsRepository(
        scenario: SampleScenario.noActiveTask,
        delay: Duration.zero,
      );
      expect(await repo.fetchActiveTask(), isNull);
    });

    test('error de carga lanza ApiException', () async {
      const repo = SampleIncidentsRepository(
        scenario: SampleScenario.loadError,
        delay: Duration.zero,
      );
      await expectLater(repo.fetchActiveTask(), throwsA(isA<ApiException>()));
    });

    test('error de envío lanza ApiException', () async {
      const repo = SampleIncidentsRepository(
        scenario: SampleScenario.submitError,
        delay: Duration.zero,
      );
      final task = (await repo.fetchActiveTask())!;
      await expectLater(
        repo.submitImpediment(
          ImpedimentReport(
            task: task,
            reason: ImpedimentReason.other,
            detail: '',
          ),
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
