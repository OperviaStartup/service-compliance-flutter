import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/authentication/presentation/account_page.dart';
import '../features/authentication/presentation/sign_in_page.dart';
import '../features/compliance/data/compliance_review_repository.dart';
import '../features/compliance/presentation/compliance_review_page.dart';
import '../features/obligations/data/operational_repository.dart';
import '../features/obligations/presentation/operational_page.dart';
import 'opervia_backdrop.dart';
import 'opervia_theme.dart';

class OperviaApp extends StatelessWidget {
  const OperviaApp({super.key, this.api});

  final ApiClient? api;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Opervia Service Compliance',
    debugShowCheckedModeBanner: false,
    theme: operviaTheme(compact: MediaQuery.sizeOf(context).width < 360),
    builder: (context, child) => OperviaBackdrop(child: child!),
    home: _HomePage(api: api),
  );
}

class _HomePage extends StatefulWidget {
  const _HomePage({required this.api});

  final ApiClient? api;

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  late final _api = widget.api ?? ApiClient();
  late final _auth = AuthRepository(_api);
  AuthSession? _session;
  int _selected = 0;

  @override
  void dispose() {
    if (widget.api == null) _api.close();
    super.dispose();
  }

  void _signOut() => setState(() {
    _session = null;
    _selected = 0;
  });

  Future<void> _openAccount(AuthSession session) async {
    final signedOut = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AccountPage(
          repository: _auth,
          session: session,
          onSignedOut: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (mounted && signedOut == true) _signOut();
  }

  void _openReview(AuthSession session, int obligationId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ComplianceReviewPage(
          repository: ComplianceReviewRepository(_api, session.token),
          obligationId: obligationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session == null) {
      return SignInPage(
        repository: _auth,
        onSignedIn: (session) => setState(() => _session = session),
      );
    }
    if (session.role != AccountRole.supervisor) {
      return AccountPage(
        repository: _auth,
        session: session,
        onSignedOut: _signOut,
      );
    }
    final section = OperationalSection.values[_selected];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opervia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Perfil',
            onPressed: () => _openAccount(session),
          ),
        ],
      ),
      body: OperviaContent(
        child: OperationalPage(
          key: ValueKey(section),
          section: section,
          repository: OperationalRepository(_api, session.token),
          onReview: (id) => _openReview(session, id),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: (index) => setState(() => _selected = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            label: 'Resumen',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Actividades',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            label: 'Casos',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}
