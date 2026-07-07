import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'app_state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TotalesState(),
      child: const TotalesApp(),
    ),
  );
}

class TotalesApp extends StatelessWidget {
  const TotalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Totales',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: const AppShell(),
    );
  }
}
