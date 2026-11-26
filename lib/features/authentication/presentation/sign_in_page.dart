import 'package:flutter/material.dart';

import '../../../app/opervia_theme.dart';
import '../../../core/network/api_client.dart';
import '../../incidents/presentation/incidents_page.dart';
import '../data/auth_repository.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
    required this.repository,
    required this.onSignedIn,
  });

  final AuthRepository repository;
  final ValueChanged<AuthSession> onSignedIn;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = await widget.repository.signIn(
        _identifier.text.trim(),
        _password.text,
      );
      if (mounted) widget.onSignedIn(session);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = switch (error.statusCode) {
          400 => 'Revisa los datos de acceso.',
          401 => 'Las credenciales son incorrectas o la cuenta está inactiva.',
          403 => 'Esta cuenta no tiene acceso.',
          _ => error.message,
        };
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showDemo() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Demostración')),
          body: const OperviaContent(child: IncidentsPage()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Opervia Service Compliance')),
      body: OperviaContent(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Iniciar sesión', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Acceso para supervisores y administradores.'),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AutofillGroup(
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _identifier,
                            autofillHints: const [AutofillHints.username],
                            enabled: !_busy,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo o documento',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) => value!.trim().isEmpty
                                ? 'Ingresa el correo o documento.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            autofillHints: const [AutofillHints.password],
                            enabled: !_busy,
                            obscureText: !_showPassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _showPassword
                                    ? 'Ocultar contraseña'
                                    : 'Mostrar contraseña',
                                onPressed: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Ingresa la contraseña.'
                                : null,
                          ),
                          if (_error case final error?) ...[
                            const SizedBox(height: 16),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                error,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _busy ? null : _submit,
                            child: Text(_busy ? 'Ingresando…' : 'Ingresar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _showDemo,
                child: const Text('Ver demostración de incidencias'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
