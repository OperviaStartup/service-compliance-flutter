// Modelos de interfaz para US07 (Reportar Impedimento).

enum ImpedimentReason { closedArea, missingSupplies, safetyRisk, other }

extension ImpedimentReasonText on ImpedimentReason {
  String get title => switch (this) {
    ImpedimentReason.closedArea => 'Área cerrada',
    ImpedimentReason.missingSupplies => 'Faltan insumos',
    ImpedimentReason.safetyRisk => 'Riesgo de seguridad',
    ImpedimentReason.other => 'Otro motivo',
  };

  String get description => switch (this) {
    ImpedimentReason.closedArea => 'Sin acceso físico o llave requerida',
    ImpedimentReason.missingSupplies =>
      'Químicos, paños o dispensadores agotados',
    ImpedimentReason.safetyRisk =>
      'Derrame crítico, cableado o riesgo biológico',
    ImpedimentReason.other => 'Requerimiento especial de cliente o evento',
  };
}

class ActiveTask {
  const ActiveTask({
    required this.id,
    required this.name,
    required this.building,
    required this.location,
    required this.schedule,
    required this.startedAt,
  });

  final String id;
  final String name;
  final String building;
  final String location;
  final String schedule;
  final String startedAt;
}

class ImpedimentReport {
  const ImpedimentReport({
    required this.task,
    required this.reason,
    required this.detail,
  });

  final ActiveTask task;
  final ImpedimentReason reason;
  final String detail;
}

class ImpedimentRecord {
  const ImpedimentRecord({required this.report, required this.sentAt});

  final ImpedimentReport report;
  final DateTime sentAt;
}
