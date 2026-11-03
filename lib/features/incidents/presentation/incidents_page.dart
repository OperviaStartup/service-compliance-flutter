import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';

class IncidentsPage extends StatelessWidget {
  const IncidentsPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Incidencias',
    description: 'Espacio reservado para la gestión de incidencias.',
    icon: Icons.report_outlined,
  );
}
