import 'package:flutter/material.dart';

import '../../../app/opervia_theme.dart';

import '../data/impediment.dart';
import 'incidents_design.dart';

/// US07 - Pantalla Registro Impedimento.
class ImpedimentRegisteredPage extends StatelessWidget {
  const ImpedimentRegisteredPage({
    super.key,
    required this.record,
    this.isSample = false,
  });

  final ImpedimentRecord record;
  final bool isSample;

  String get _time {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(record.sentAt.hour)}:${two(record.sentAt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final report = record.report;
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de impedimento')),
      body: OperviaContent(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isSample) const SampleDataBanner(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: OperviaColors.amberBg,
                        child: Icon(
                          Icons.pending_actions,
                          size: 40,
                          color: OperviaColors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isSample
                          ? 'Simulación de reporte'
                          : 'Impedimento registrado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: OperviaColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSample
                          ? 'Ejemplo generado a las $_time'
                          : 'Enviado hoy, $_time',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: OperviaColors.muted),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'DETALLE DEL REPORTE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: OperviaColors.muted,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: OperviaColors.amberBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Por revisar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: OperviaColors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DetailTile(
                      icon: Icons.cleaning_services_outlined,
                      label: 'Tarea asignada',
                      value: report.task.name,
                    ),
                    _DetailTile(
                      icon: Icons.apartment_outlined,
                      label: 'Ubicación y sede',
                      value: report.task.building,
                    ),
                    _DetailTile(
                      icon: Icons.lock_outline,
                      label: 'Motivo reportado',
                      value: report.reason.title,
                      background: OperviaColors.amberBg,
                      foreground: OperviaColors.amber,
                    ),
                    if (report.detail.isNotEmpty)
                      _DetailTile(
                        icon: Icons.notes,
                        label: 'Detalle',
                        value: report.detail,
                      ),
                    const SizedBox(height: 4),
                    WhiteCard(
                      color: OperviaColors.tint,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: OperviaColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSample
                                  ? 'Este ejemplo no envía datos a supervisión.'
                                  : 'Pendiente de revisión por supervisión.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'VOLVER A MIS TAREAS',
                      icon: Icons.arrow_back,
                      onPressed: () =>
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.background = OperviaColors.tint,
    this.foreground = OperviaColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: WhiteCard(
      child: Row(
        children: [
          IconSquare(
            icon: icon,
            background: background,
            foreground: foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: OperviaColors.muted,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: OperviaColors.navy,
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
