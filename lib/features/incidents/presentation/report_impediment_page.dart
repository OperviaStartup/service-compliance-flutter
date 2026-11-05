import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../data/impediment.dart';
import '../data/incidents_repository.dart';
import 'impediment_registered_page.dart';
import 'incidents_design.dart';

/// US07 - Pantalla Reportar Impedimento.
class ReportImpedimentPage extends StatefulWidget {
  const ReportImpedimentPage({
    super.key,
    required this.repository,
    required this.task,
  });

  final IncidentsRepository repository;
  final ActiveTask task;

  @override
  State<ReportImpedimentPage> createState() => _ReportImpedimentPageState();
}

class _ReportImpedimentPageState extends State<ReportImpedimentPage> {
  final _detail = TextEditingController();
  ImpedimentReason _reason = ImpedimentReason.closedArea;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final record = await widget.repository.submitImpediment(
        ImpedimentReport(
          task: widget.task,
          reason: _reason,
          detail: _detail.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ImpedimentRegisteredPage(
            record: record,
            isSample: widget.repository.isSampleData,
          ),
        ),
      );
    } on ApiException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('No se pudo enviar el reporte.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = message;
    });
  }

  IconData _iconFor(ImpedimentReason reason) => switch (reason) {
    ImpedimentReason.closedArea => Icons.lock_outline,
    ImpedimentReason.missingSupplies => Icons.inventory_2_outlined,
    ImpedimentReason.safetyRisk => Icons.warning_amber_outlined,
    ImpedimentReason.other => Icons.edit_note,
  };

  Widget _reasonCard(ImpedimentReason reason) {
    final selected = reason == _reason;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _sending ? null : () => setState(() => _reason = reason),
        child: WhiteCard(
          color: selected ? FigmaColors.greenBg : Colors.white,
          borderColor: selected ? FigmaColors.green : null,
          child: Row(
            children: [
              IconSquare(
                icon: _iconFor(reason),
                background: selected ? Colors.white : FigmaColors.tint,
                foreground: selected ? FigmaColors.green : FigmaColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reason.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: FigmaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? FigmaColors.green : FigmaColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FigmaHeader(title: 'Reportar Impedimento'),
              if (widget.repository.isSampleData) const SampleDataBanner(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Row(
                      children: [
                        const IconSquare(icon: Icons.assignment_outlined),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TAREA EN CURSO',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: FigmaColors.muted,
                                ),
                              ),
                              Text(
                                widget.task.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: FigmaColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selecciona el motivo principal:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: FigmaColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final reason in ImpedimentReason.values)
                      _reasonCard(reason),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Añadir detalle (opcional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: FigmaColors.navy,
                            ),
                          ),
                        ),
                        Text(
                          '${_detail.text.length}/120',
                          style: const TextStyle(
                            fontSize: 12,
                            color: FigmaColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    WhiteCard(
                      child: TextField(
                        controller: _detail,
                        enabled: !_sending,
                        maxLength: 120,
                        maxLines: 3,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'Describe brevemente lo ocurrido',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    WhiteCard(
                      color: FigmaColors.amberBg,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: FigmaColors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Revisión de Supervisor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: FigmaColors.navy,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Esta solicitud será enviada como excepción '
                                  'para revisión del supervisor.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FigmaColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: FigmaColors.error),
                        ),
                      ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'ENVIAR PARA REVISIÓN',
                      icon: Icons.send_outlined,
                      loading: _sending,
                      onPressed: _submit,
                    ),
                    TextButton(
                      onPressed: _sending
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Descartar y volver a la tarea',
                        style: TextStyle(color: FigmaColors.navy),
                      ),
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
