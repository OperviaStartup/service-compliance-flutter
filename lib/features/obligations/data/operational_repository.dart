import '../../../core/network/api_client.dart';

enum OperationalStatus {
  assigned('ASSIGNED', 'Asignada'),
  inProgress('IN_PROGRESS', 'En curso'),
  submitted('SUBMITTED', 'Enviada'),
  excepted('EXCEPTED', 'Con excepción'),
  overdue('OVERDUE', 'Vencida');

  const OperationalStatus(this.value, this.label);
  final String value;
  final String label;

  bool get canReview => this == submitted || this == excepted;

  static OperationalStatus parse(String value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    throw const ApiException(
      'La API devolvió un estado operativo desconocido.',
    );
  }
}

class OperationalObligation {
  const OperationalObligation({
    required this.id,
    required this.activity,
    required this.site,
    required this.operator,
    required this.dueAt,
    required this.status,
  });

  factory OperationalObligation.fromJson(Object? json) {
    if (json case {
      'obligationId': final int id,
      'activity': final String activity,
      'siteName': final String site,
      'operatorName': final String? operator,
      'dueAt': final String due,
      'status': final String status,
    }) {
      final dueAt = DateTime.tryParse(due);
      if (dueAt != null) {
        return OperationalObligation(
          id: id,
          activity: activity,
          site: site,
          operator: operator,
          dueAt: dueAt,
          status: OperationalStatus.parse(status),
        );
      }
    }
    throw const ApiException('La API devolvió una obligación inválida.');
  }

  final int id;
  final String activity;
  final String site;
  final String? operator;
  final DateTime dueAt;
  final OperationalStatus status;
}

class OperationalPageData {
  const OperationalPageData({
    required this.items,
    required this.counts,
    required this.total,
    required this.nextCursor,
  });

  factory OperationalPageData.fromJson(Object? json) {
    if (json case {
      'items': final List<Object?> items,
      'counts': final Map<String, Object?> counts,
      'total': final int total,
      'nextCursor': final String? cursor,
    }) {
      return OperationalPageData(
        items: items.map(OperationalObligation.fromJson).toList(),
        counts: {
          for (final status in OperationalStatus.values)
            status: switch (counts[status.value]) {
              final int count => count,
              null => 0,
              _ => throw const ApiException(
                'La API devolvió conteos operativos inválidos.',
              ),
            },
        },
        total: total,
        nextCursor: cursor,
      );
    }
    throw const ApiException(
      'La API devolvió una consulta operativa inválida.',
    );
  }

  final List<OperationalObligation> items;
  final Map<OperationalStatus, int> counts;
  final int total;
  final String? nextCursor;
}

class OperationalRepository {
  const OperationalRepository(this._api, this._token);

  final ApiClient _api;
  final String _token;

  Future<OperationalPageData> query({
    DateTime? fromDate,
    DateTime? toDate,
    int? siteId,
    int? serviceId,
    Set<OperationalStatus> statuses = const {},
    String? cursor,
  }) async {
    final path = Uri(
      path: '/api/v1/operational-obligations',
      queryParameters: {
        if (fromDate != null) 'fromDate': _date(fromDate),
        if (toDate != null) 'toDate': _date(toDate),
        if (siteId != null) 'siteId': '$siteId',
        if (serviceId != null) 'serviceId': '$serviceId',
        if (statuses.isNotEmpty)
          'status': statuses.map((status) => status.value).join(','),
        'cursor': ?cursor,
      },
    );
    return OperationalPageData.fromJson(
      await _api.get(path.toString(), token: _token),
    );
  }

  String _date(DateTime value) => value.toIso8601String().split('T').first;
}
