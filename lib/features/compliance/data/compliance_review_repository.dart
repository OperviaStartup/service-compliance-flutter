import 'dart:typed_data';

import '../../../core/network/api_client.dart';

class ComplianceReview {
  const ComplianceReview({
    required this.obligation,
    required this.execution,
    required this.evidence,
    required this.exceptions,
    required this.missingInformation,
  });

  factory ComplianceReview.fromJson(Object? json) {
    if (json case {
      'obligation': final Map<String, Object?> obligation,
      'execution': final Map<String, Object?> execution,
      'evidence': final List<Object?> evidence,
      'exceptions': final List<Object?> exceptions,
      'missingInformation': final List<Object?> missingInformation,
    }) {
      return ComplianceReview(
        obligation: obligation,
        execution: execution,
        evidence: _rows(evidence),
        exceptions: _rows(exceptions),
        missingInformation: _rows(missingInformation),
      );
    }
    throw const ApiException('La API devolvió una revisión inválida.');
  }

  static List<Map<String, Object?>> _rows(List<Object?> values) => [
    for (final value in values)
      if (value is Map<String, Object?>)
        value
      else
        throw const ApiException('La revisión contiene un registro inválido.'),
  ];

  final Map<String, Object?> obligation;
  final Map<String, Object?> execution;
  final List<Map<String, Object?>> evidence;
  final List<Map<String, Object?>> exceptions;
  final List<Map<String, Object?>> missingInformation;
}

class ComplianceReviewRepository {
  const ComplianceReviewRepository(this._api, this._token);

  final ApiClient _api;
  final String _token;

  Future<ComplianceReview> review(int obligationId) async {
    final execution = await _api.get(
      '/api/v1/obligations/$obligationId/execution',
      token: _token,
    );
    if (execution case {'id': final int executionId}) {
      return ComplianceReview.fromJson(
        await _api.get(
          '/api/v1/compliance-reviews/executions/$executionId',
          token: _token,
        ),
      );
    }
    throw const ApiException('La API devolvió una ejecución inválida.');
  }

  Future<Uint8List> photo(int evidenceId) =>
      _api.getImage('/api/v1/evidence/$evidenceId/content', token: _token);
}
