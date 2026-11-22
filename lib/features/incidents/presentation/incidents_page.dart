import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../about_product/presentation/about_product_page.dart';
import '../data/impediment.dart';
import '../data/incidents_repository.dart';
import 'incidents_design.dart';
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
    return GradientBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSample) const SampleDataBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Incidencias',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: FigmaColors.navy,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Acerca del producto',
                  icon: const Icon(Icons.info_outline, color: FigmaColors.navy),
                  onPressed: _openAbout,
                ),
                if (widget.repository == null)
                  PopupMenuButton<SampleScenario>(
                    tooltip: 'Simular estado (solo demo)',
                    icon: const Icon(Icons.tune, color: FigmaColors.navy),
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
      ),
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
            FilledButton(
              onPressed: () => _openReport(task),
              style: FilledButton.styleFrom(
                backgroundColor: FigmaColors.tint,
                foregroundColor: FigmaColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_outlined, size: 20),
                  SizedBox(width: 10),
                  Text('Reportar impedimento o incidencia'),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 52, color: FigmaColors.green),
          SizedBox(height: 16),
          Text(
            'No tienes una actividad en curso.',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: FigmaColors.navy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando inicies una actividad podrás reportar un impedimento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: FigmaColors.muted),
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
  Widget build(BuildContext context) => WhiteCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: FigmaColors.greenBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'EN CURSO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: FigmaColors.green,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          task.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: FigmaColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${task.building} · ${task.location}',
          style: const TextStyle(color: FigmaColors.muted),
        ),
        const SizedBox(height: 4),
        Text(
          '${task.schedule} · Iniciada ${task.startedAt}',
          style: const TextStyle(color: FigmaColors.muted),
        ),
      ],
    ),
  );
}
