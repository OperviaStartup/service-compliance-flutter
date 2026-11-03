import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';

class CompliancePage extends StatelessWidget {
  const CompliancePage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Cumplimiento',
    description: 'Seguimiento de ejecuciones y evidencias.',
    icon: Icons.fact_check_outlined,
  );
}
