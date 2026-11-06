import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../about_product/presentation/about_product_page.dart';
import '../data/impediment.dart';
import '../data/incidents_repository.dart';
import 'report_impediment_page.dart';

enum _ViewStatus { loading, empty, error, ready }

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key, this.repository});

  /// Si es null se usan datos de muestra (con selector de estados demo).
  final IncidentsRepository? repository;

  @override
  State<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {
  _ViewStatus _status = _ViewStatus.loading;
  ActiveTask? _task;
  String _errorMessage = '';
  SampleScenario _scenario = SampleScenario.normal;
  int _requestId = 0;

  IncidentsRepository get _repository =>
      widget.repository ?? SampleIncidentsRepository(scenario: _scenario);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    try {
      final task = await _repository.fetchActiveTask();
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _task = task;
        _status = task == null ? _ViewStatus.empty : _ViewStatus.ready;
      });
    } on ApiException catch (error) {
      _fail(requestId, error.message);
    } catch (_) {
      _fail(requestId, 'No se pudo cargar la actividad en curso.');
    }
  }

  void _fail(int requestId, String message) {
    if (!mounted || requestId != _requestId) return;
    setState(() {
      _errorMessage = message;
      _status = _ViewStatus.error;
    });
  }

  void _reload() {
    setState(() => _status = _ViewStatus.loading);
    _load();
  }

  void _selectScenario(SampleScenario scenario) {
    _scenario = scenario;
    _reload();
  }

  void _openAbout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AboutProductPage()));
  }

  void _openReport(ActiveTask task) {
    final repository = _repository;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ReportImpedimentPage(repository: repository, task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSample = widget.repository?.isSampleData ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSample) const SampleDataBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Incidencias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Acerca del producto',
                icon: const Icon(Icons.info_outline),
                onPressed: _openAbout,
              ),
              if (widget.repository == null)
                PopupMenuButton<SampleScenario>(
                  tooltip: 'Simular estado (solo demo)',
                  icon: const Icon(Icons.tune),
                  onSelected: _selectScenario,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: SampleScenario.normal,
                      child: Text('Normal'),
                    ),
                    PopupMenuItem(
                      value: SampleScenario.noActiveTask,
                      child: Text('Sin actividad en curso'),
                    ),
                    PopupMenuItem(
                      value: SampleScenario.loadError,
                      child: Text('Error al cargar'),
                    ),
                    PopupMenuItem(
                      value: SampleScenario.submitError,
                      child: Text('Error al enviar'),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _ViewStatus.loading:
        return const LoadingView();
      case _ViewStatus.error:
        return ErrorView(message: _errorMessage, onRetry: _reload);
      case _ViewStatus.empty:
        return const _EmptyView();
      case _ViewStatus.ready:
        final task = _task!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ActiveTaskCard(task: task),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openReport(task),
              icon: const Icon(Icons.warning_amber_outlined),
              label: const Text('Reportar impedimento o incidencia'),
            ),
          ],
        );
    }
  }
}

/// Rótulo visible mientras los datos no vengan del backend.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.science_outlined,
            size: 18,
            color: scheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'DATOS DE MUESTRA · Sin conexión con el backend '
              '(aún no existe el contrato de incidencias).',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          const Text('No tienes una actividad en curso.'),
          const SizedBox(height: 8),
          const Text(
            'Cuando inicies una actividad podrás reportar un impedimento.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ActiveTaskCard extends StatelessWidget {
  const _ActiveTaskCard({required this.task});

  final ActiveTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EN CURSO', style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(task.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${task.building} · ${task.location}'),
            const SizedBox(height: 4),
            Text('${task.schedule} · Iniciada ${task.startedAt}'),
          ],
        ),
      ),
    );
  }
}
