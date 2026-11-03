import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';

class ObligationsPage extends StatelessWidget {
  const ObligationsPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Obligaciones',
    description: 'Consulta de obligaciones operativas.',
    icon: Icons.assignment_outlined,
  );
}
