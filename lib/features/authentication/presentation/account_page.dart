import 'package:flutter/material.dart';

import '../../../app/opervia_theme.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.repository,
    required this.session,
    required this.onSignedOut,
  });

  final AuthRepository repository;
  final AuthSession session;
  final VoidCallback onSignedOut;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _closing = false;
  bool _signOutFailed = false;

  Future<void> _signOut() async {
    setState(() => _closing = true);
    try {
      await widget.repository.signOut(widget.session);
      if (mounted) widget.onSignedOut();
    } on ApiException {
      if (mounted) {
        setState(() {
          _closing = false;
          _signOutFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: OperviaContent(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(session.name),
                  subtitle: Text('${session.email}\n${session.role.label}'),
                ),
              ),
              if (session.role == AccountRole.operator)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Para consultar tus tareas, usa la aplicación de operarios.',
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _closing ? null : _signOut,
                child: Text(_closing ? 'Cerrando…' : 'Cerrar sesión'),
              ),
              if (_signOutFailed) ...[
                const Text('No se pudo cerrar la sesión en el servidor.'),
                TextButton(
                  onPressed: _closing ? null : widget.onSignedOut,
                  child: const Text('Salir en este dispositivo'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
