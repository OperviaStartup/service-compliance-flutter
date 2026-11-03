import 'package:flutter/material.dart';

import '../../../core/widgets/feature_placeholder.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});
  @override
  Widget build(BuildContext context) => const FeaturePlaceholder(
    title: 'Autenticación',
    description: 'Acceso y perfil de usuario.',
    icon: Icons.person_outline,
  );
}
