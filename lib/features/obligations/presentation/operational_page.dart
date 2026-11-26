import 'package:flutter/material.dart';

import '../../../app/opervia_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/async_state_view.dart';
import '../data/operational_repository.dart';

enum OperationalSection {
  summary('Resumen operativo', 'Obligaciones dentro de tu alcance.'),
  activities('Actividades', 'Consulta obligaciones, responsables y plazos.'),
  cases('Casos', 'Abre una ejecución enviada para revisar la evidencia.'),
  reports(
    'Reportes',
    'Consulta los totales operativos por periodo y servicio.',
  );

  const OperationalSection(this.title, this.description);
  final String title;
  final String description;
}

class OperationalPage extends StatefulWidget {
  const OperationalPage({
    super.key,
    required this.section,
    required this.repository,
    required this.onReview,
  });

  final OperationalSection section;
  final OperationalRepository repository;
  final ValueChanged<int> onReview;

  @override
  State<OperationalPage> createState() => _OperationalPageState();
}

class _OperationalPageState extends State<OperationalPage> {
  late Future<OperationalPageData> _future;
  DateTimeRange? _period;
  OperationalStatus? _status;
  int? _siteId;
  int? _serviceId;

  bool get _isSummary => widget.section == OperationalSection.summary;
  bool get _showsList => switch (widget.section) {
    OperationalSection.activities || OperationalSection.cases => true,
    _ => false,
  };

  @override
  void initState() {
    super.initState();
    _future = _query();
  }

  Future<OperationalPageData> _query({OperationalPageData? previous}) async {
    final statuses = widget.section == OperationalSection.cases
        ? {OperationalStatus.submitted, OperationalStatus.excepted}
        : {?_status};
    final page = await widget.repository.query(
      fromDate: _period?.start,
      toDate: _period?.end,
      siteId: _siteId,
      serviceId: _serviceId,
      statuses: statuses,
      cursor: previous?.nextCursor,
    );
    if (previous == null) return page;
    return OperationalPageData(
      items: [...previous.items, ...page.items],
      counts: page.counts,
      total: page.total,
      nextCursor: page.nextCursor,
    );
  }

  void _reload() => setState(() => _future = _query());

  Future<void> _pickPeriod() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _period,
      helpText: 'Selecciona el periodo',
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
    );
    if (!mounted || range == null) return;
    _period = range;
    _reload();
  }

  Future<void> _pickScope() async {
    final choice = await showDialog<(int?, int?)>(
      context: context,
      builder: (_) => _ScopeDialog(siteId: _siteId, serviceId: _serviceId),
    );
    if (!mounted || choice == null) return;
    _siteId = choice.$1;
    _serviceId = choice.$2;
    _reload();
  }

  String _date(DateTime value) =>
      MaterialLocalizations.of(context).formatCompactDate(value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = widget.section;
    return SafeArea(
      top: false,
      child: FutureBuilder<OperationalPageData>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final loading = snapshot.connectionState == ConnectionState.waiting;
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              try {
                await _future;
              } on ApiException {
                // The FutureBuilder shows the error and retry action.
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(section.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(section.description),
                if (!_isSummary)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.date_range_outlined),
                          label: Text(
                            _period == null
                                ? 'Periodo'
                                : '${_date(_period!.start)} – ${_date(_period!.end)}',
                          ),
                          onPressed: _pickPeriod,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.filter_list),
                          label: const Text('Sede y servicio'),
                          onPressed: _pickScope,
                        ),
                        if (section == OperationalSection.activities)
                          DropdownButton<OperationalStatus>(
                            value: _status,
                            hint: const Text('Todos los estados'),
                            items: [
                              const DropdownMenuItem(
                                child: Text('Todos los estados'),
                              ),
                              for (final status in OperationalStatus.values)
                                DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
                                ),
                            ],
                            onChanged: (status) {
                              _status = status;
                              _reload();
                            },
                          ),
                        if (_period != null ||
                            _status != null ||
                            _siteId != null ||
                            _serviceId != null)
                          TextButton(
                            onPressed: () {
                              _period = null;
                              _status = null;
                              _siteId = null;
                              _serviceId = null;
                              _reload();
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  ),
                if (_siteId != null || _serviceId != null)
                  Text(
                    [
                      if (_siteId != null) 'Sede $_siteId',
                      if (_serviceId != null) 'Servicio $_serviceId',
                    ].join(' · '),
                  ),
                const SizedBox(height: 16),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: LoadingView(),
                  )
                else if (snapshot.error case final Object error)
                  ErrorView(
                    message: switch (error) {
                      ApiException(statusCode: 401) =>
                        'Tu sesión venció. Ingresa de nuevo desde Perfil.',
                      ApiException(statusCode: 403) =>
                        'La consulta está fuera de tu alcance.',
                      ApiException(:final message) => message,
                      _ => 'No se pudo cargar el estado operativo.',
                    },
                    onRetry: _reload,
                  )
                else if (data != null) ...[
                  if (!_showsList) _StatusCounts(data: data),
                  if (_showsList && data.items.isEmpty)
                    const Text('No hay obligaciones para estos filtros.'),
                  if (_showsList)
                    for (final item in data.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: const Icon(Icons.assignment_outlined),
                            title: Text(item.activity),
                            subtitle: Text(
                              '${item.site} · ${item.status.label}\n'
                              '${item.operator ?? 'Sin responsable'} · '
                              'Vence ${_date(item.dueAt.toLocal())}',
                            ),
                            trailing: item.status.canReview
                                ? const Icon(Icons.chevron_right)
                                : null,
                            onTap: item.status.canReview
                                ? () => widget.onReview(item.id)
                                : null,
                          ),
                        ),
                      ),
                  if (_showsList && data.nextCursor != null)
                    OutlinedButton(
                      onPressed: () =>
                          setState(() => _future = _query(previous: data)),
                      child: const Text('Cargar más'),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusCounts extends StatelessWidget {
  const _StatusCounts({required this.data});
  final OperationalPageData data;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            data.total == 1 ? '1 obligación' : '${data.total} obligaciones',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final status in OperationalStatus.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(status.label)),
                  Text(
                    '${data.counts[status] ?? 0}',
                    style: const TextStyle(
                      color: OperviaColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _ScopeDialog extends StatefulWidget {
  const _ScopeDialog({required this.siteId, required this.serviceId});
  final int? siteId;
  final int? serviceId;

  @override
  State<_ScopeDialog> createState() => _ScopeDialogState();
}

class _ScopeDialogState extends State<_ScopeDialog> {
  final _form = GlobalKey<FormState>();
  late final _site = TextEditingController(text: widget.siteId?.toString());
  late final _service = TextEditingController(
    text: widget.serviceId?.toString(),
  );

  @override
  void dispose() {
    _site.dispose();
    _service.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || (int.tryParse(text) ?? 0) > 0) return null;
    return 'Ingresa un código numérico positivo.';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Sede y servicio'),
    scrollable: true,
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _site,
            decoration: const InputDecoration(labelText: 'Código de sede'),
            keyboardType: TextInputType.number,
            validator: _validate,
          ),
          TextFormField(
            controller: _service,
            decoration: const InputDecoration(labelText: 'Código de servicio'),
            keyboardType: TextInputType.number,
            validator: _validate,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.of(context).pop((
            int.tryParse(_site.text.trim()),
            int.tryParse(_service.text.trim()),
          ));
        },
        child: const Text('Aplicar'),
      ),
    ],
  );
}
