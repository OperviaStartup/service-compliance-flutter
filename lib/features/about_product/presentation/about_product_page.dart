import 'package:flutter/material.dart';

/// Primer corte de About Product: problema, usuarios, solución y demo
/// basada en lo que la app muestra hoy.
class AboutProductPage extends StatelessWidget {
  const AboutProductPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Acerca del producto')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _Header(),
        _Section(
          title: 'El problema',
          icon: Icons.warning_amber_outlined,
          paragraphs: [
            'Las empresas de limpieza B2B trabajan dentro de las '
                'instalaciones de sus clientes. El plan de servicio, la '
                'ejecución en campo, la supervisión y la evidencia suelen '
                'quedar dispersos.',
            'Resultado: es difícil reconstruir qué debía hacerse, qué '
                'ocurrió y cómo se atendieron las desviaciones.',
          ],
        ),
        _Section(
          title: 'Usuarios',
          icon: Icons.groups_outlined,
          items: [
            'Supervisores: revisan el cumplimiento, detectan desviaciones y '
                'dan seguimiento a las acciones correctivas.',
            'Operarios: ejecutan las obligaciones asignadas y aportan '
                'evidencia del trabajo realizado.',
            'Empresa prestadora y sus clientes: reciben información '
                'trazable de cumplimiento.',
          ],
        ),
        _Section(
          title: 'La solución',
          icon: Icons.verified_outlined,
          paragraphs: [
            'Service Compliance relaciona lo planificado con lo ejecutado y '
                'su evidencia, para que supervisores y operarios trabajen '
                'sobre una referencia común.',
          ],
        ),
        _Section(
          title: 'Demo: lo que ya se ve en la app',
          icon: Icons.play_circle_outline,
          paragraphs: [
            'Recorrido breve por Incidencias (reportar impedimento):',
          ],
          items: [
            '1. Entra a la pestaña Incidencias: se muestra la actividad en '
                'curso (Limpieza de recepción).',
            '2. Pulsa "Reportar impedimento o incidencia".',
            '3. Elige el motivo (Área cerrada, Faltan insumos, Riesgo de '
                'seguridad u Otro motivo) y añade un detalle opcional.',
            '4. Pulsa "Enviar para revisión": aparece la confirmación '
                '"Impedimento registrado". El envío es simulado.',
          ],
        ),
        _Section(
          title: 'Estado actual',
          icon: Icons.fact_check_outlined,
          items: [
            'Incidencias: flujo de reporte de impedimento con estados de '
                'carga, vacío y error. Usa datos de muestra.',
            'No está conectada al backend: hoy no existe un controlador de '
                'incidencias. Falta confirmar el contrato.',
            'Obligaciones, Cumplimiento y Cuenta: espacios reservados, aún '
                'sin implementar.',
          ],
        ),
      ],
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opervia Service Compliance',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Gestión del cumplimiento de servicios tercerizados, '
            'empezando por limpieza B2B.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    this.paragraphs = const [],
    this.items = const [],
  });

  final String title;
  final IconData icon;
  final List<String> paragraphs;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            for (final text in paragraphs)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(text),
              ),
            for (final text in items)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(text),
              ),
          ],
        ),
      ),
    );
  }
}
