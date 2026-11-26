import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/opervia_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/async_state_view.dart';
import '../data/compliance_review_repository.dart';

class ComplianceReviewPage extends StatefulWidget {
  const ComplianceReviewPage({
    super.key,
    required this.repository,
    required this.obligationId,
  });

  final ComplianceReviewRepository repository;
  final int obligationId;

  @override
  State<ComplianceReviewPage> createState() => _ComplianceReviewPageState();
}

class _ComplianceReviewPageState extends State<ComplianceReviewPage> {
  late Future<ComplianceReview> _review;

  @override
  void initState() {
    super.initState();
    _review = widget.repository.review(widget.obligationId);
  }

  void _showPhoto(int id) {
    final photo = widget.repository.photo(id);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Evidencia fotográfica'),
        content: FutureBuilder<Uint8List>(
          future: photo,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('No se pudo mostrar la fotografía.');
            }
            if (!snapshot.hasData) {
              return const Center(
                heightFactor: 2,
                child: CircularProgressIndicator(),
              );
            }
            return Image.memory(
              snapshot.data!,
              semanticLabel: 'Fotografía de la ejecución',
              errorBuilder: (_, _, _) =>
                  const Text('No se pudo mostrar la fotografía.'),
            );
          },
        ),
        actions: [
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }

  String _time(Object? timestamp) {
    final date = timestamp is String ? DateTime.tryParse(timestamp) : null;
    if (date == null) return 'Sin registro';
    final local = date.toLocal();
    final labels = MaterialLocalizations.of(context);
    return '${labels.formatCompactDate(local)} · '
        '${labels.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Revisar ejecución')),
    body: OperviaContent(
      child: SafeArea(
        top: false,
        child: FutureBuilder<ComplianceReview>(
          future: _review,
          builder: (context, snapshot) {
            if (snapshot.error case final Object error) {
              return ErrorView(
                message: switch (error) {
                  ApiException(statusCode: 404) =>
                    'La ejecución no existe o está fuera de tu alcance.',
                  ApiException(statusCode: 409) =>
                    'La ejecución aún no está disponible para revisión.',
                  ApiException(:final message) => message,
                  _ => 'No se pudo cargar la revisión.',
                },
                onRetry: () => setState(
                  () => _review = widget.repository.review(widget.obligationId),
                ),
              );
            }
            final review = snapshot.data;
            if (review == null) return const LoadingView();
            final execution = review.execution;
            final operator = execution['operator'];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  review.obligation['title']?.toString() ?? 'Obligación',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (review.obligation['siteName'] case final String site)
                  Text(site),
                _ReviewSection(
                  title: 'Ejecución declarada',
                  children: [
                    if (operator case {'fullName': final String name})
                      Text(name),
                    Text(
                      'Resultado declarado · ${switch (execution['result']) {
                        'COMPLETED' => 'Completada',
                        'PARTIAL' => 'Parcial',
                        'BLOCKED' => 'Bloqueada',
                        final String value => value,
                        _ => 'Sin registro',
                      }}',
                    ),
                    Text('Inicio · ${_time(execution['startedAt'])}'),
                    Text('Envío · ${_time(execution['submittedAt'])}'),
                    if (execution['notes'] case final String notes
                        when notes.trim().isNotEmpty)
                      Text(notes),
                  ],
                ),
                _ReviewSection(
                  title: 'Evidencias',
                  children: [
                    if (review.evidence.isEmpty)
                      const Text('Sin evidencia registrada.'),
                    for (final row in review.evidence)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(switch (row['type']) {
                          'PHOTO' => 'Fotografía',
                          'QR_CODE' => 'Código QR',
                          'SIGNATURE' => 'Firma',
                          'LOCATION' => 'Ubicación',
                          final String value => value,
                          _ => 'Evidencia',
                        }),
                        subtitle: Text(
                          [
                            if (row['textValue'] case final String value) value,
                            if (row['latitude'] != null &&
                                row['longitude'] != null)
                              '${row['latitude']}, ${row['longitude']}',
                            _time(row['capturedAt'] ?? row['createdAt']),
                          ].join('\n'),
                        ),
                        trailing: switch (row) {
                          {'id': final int id, 'contentPath': String()} =>
                            IconButton(
                              tooltip: 'Ver fotografía',
                              onPressed: () => _showPhoto(id),
                              icon: const Icon(Icons.photo_outlined),
                            ),
                          _ => null,
                        },
                      ),
                  ],
                ),
                _ReviewSection(
                  title: 'Excepciones',
                  children: [
                    if (review.exceptions.isEmpty)
                      const Text('Sin excepciones registradas.'),
                    for (final row in review.exceptions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(row['reason']?.toString() ?? 'Excepción'),
                        subtitle: Text(
                          [
                            if (row['description'] case final String value)
                              value,
                            _time(row['reportedAt']),
                          ].join('\n'),
                        ),
                      ),
                  ],
                ),
                if (review.missingInformation.isNotEmpty)
                  _ReviewSection(
                    title: 'Información faltante',
                    children: [
                      for (final row in review.missingInformation)
                        Text(
                          '${row['category']} · ${row['code']} · '
                          '${row['actualCount']} de ${row['expectedCount']}',
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            ...children,
          ],
        ),
      ),
    ),
  );
}
