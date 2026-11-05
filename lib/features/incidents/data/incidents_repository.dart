import '../../../core/network/api_client.dart';
import 'impediment.dart';

/// Fuente de datos del flujo de impedimentos.
///
/// Cuando backend publique un contrato, se agrega una implementación que
/// reciba `ApiClient` (core/network) y la UI no cambia.
abstract class IncidentsRepository {
  const IncidentsRepository();

  /// Indica que los datos no vienen del backend.
  bool get isSampleData => false;

  /// Actividad en curso del operario, o null si no tiene ninguna.
  Future<ActiveTask?> fetchActiveTask();

  Future<ImpedimentRecord> submitImpediment(ImpedimentReport report);
}

enum SampleScenario { normal, noActiveTask, loadError, submitError }

/// DATOS DE MUESTRA. No hace ninguna petición de red.
class SampleIncidentsRepository extends IncidentsRepository {
  const SampleIncidentsRepository({
    this.scenario = SampleScenario.normal,
    this.delay = const Duration(milliseconds: 900),
  });

  final SampleScenario scenario;
  final Duration delay;

  @override
  bool get isSampleData => true;

  @override
  Future<ActiveTask?> fetchActiveTask() async {
    await Future<void>.delayed(delay);
    switch (scenario) {
      case SampleScenario.noActiveTask:
        return null;
      case SampleScenario.loadError:
        throw const ApiException(
          'Error simulado: no se pudo cargar la actividad.',
        );
      case SampleScenario.normal:
      case SampleScenario.submitError:
        return _task;
    }
  }

  @override
  Future<ImpedimentRecord> submitImpediment(ImpedimentReport report) async {
    await Future<void>.delayed(delay);
    if (scenario == SampleScenario.submitError) {
      throw const ApiException('Error simulado: no se pudo enviar el reporte.');
    }
    return ImpedimentRecord(report: report, sentAt: DateTime.now());
  }

  static const ActiveTask _task = ActiveTask(
    id: 'muestra-1',
    name: 'Limpieza de recepción',
    building: 'Edificio Central · Piso 1',
    location: 'Recepción principal',
    schedule: '10:00 - 10:30',
    startedAt: '10:04',
  );
}
