import 'package:flutter/material.dart';

import '../features/authentication/presentation/authentication_page.dart';
import '../features/compliance/presentation/compliance_page.dart';
import '../features/incidents/presentation/incidents_page.dart';
import '../features/obligations/presentation/obligations_page.dart';

class OperviaApp extends StatelessWidget {
  const OperviaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Opervia Service Compliance',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff205b62)),
      useMaterial3: true,
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  static const pages = [
    ObligationsPage(),
    CompliancePage(),
    IncidentsPage(),
    AuthenticationPage(),
  ];
  static const labels = [
    'Obligaciones',
    'Cumplimiento',
    'Incidencias',
    'Cuenta',
  ];
  static const icons = [
    Icons.assignment_outlined,
    Icons.fact_check_outlined,
    Icons.report_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Opervia Service Compliance')),
    body: pages[selected],
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) => setState(() => selected = index),
      destinations: [
        for (var i = 0; i < labels.length; i++)
          NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
      ],
    ),
  );
}
