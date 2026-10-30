import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

Future<void> _syncPost(Map<String, dynamic> payload) async {
  try {
    final res = await http
        .post(
          Uri.parse(syncCierreJornadaUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 15));
    if (!res.statusCode.toString().startsWith('2')) {
      // ignorar
    }
  } catch (_) {
    // red u otro error: silencioso
  }
}

/// POST silencioso al script; no lanza si falla la red.
Future<void> syncCerrarJornada(Map<String, List<int>> clientes) async {
  final fecha = DateTime.now().toIso8601String().split('T').first;
  final bolsas = <Map<String, dynamic>>[];

  clientes.forEach((nombre, valores) {
    if (valores.isEmpty) return;
    final montoTotal = valores.fold<int>(0, (a, b) => a + b);
    bolsas.add({
      'cliente': nombre,
      'cantidadProductos': valores.length,
      'montoTotal': montoTotal,
    });
  });

  if (bolsas.isEmpty) return;

  await _syncPost({
    'tipo': 'cierre',
    'fecha': fecha,
    'bolsas': bolsas,
  });
}

Future<void> syncEnvios(List<Map<String, dynamic>> eventos) async {
  if (eventos.isEmpty) return;
  final fecha = DateTime.now().toIso8601String().split('T').first;
  await _syncPost({
    'tipo': 'envio',
    'fecha': fecha,
    'eventos': eventos,
  });
}
