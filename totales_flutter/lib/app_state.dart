import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/sync_service.dart';

const _storageKey = 'totales_app_data';

class Bolsa {
  Bolsa({
    required this.fecha,
    required this.cantidadItems,
    required this.montoTotal,
    this.jornada = '',
  });

  final String fecha;
  final int cantidadItems;
  final int montoTotal;
  final String jornada;

  Map<String, dynamic> toJson() => {
        'fecha': fecha,
        'cantidadItems': cantidadItems,
        'montoTotal': montoTotal,
        'jornada': jornada,
      };

  factory Bolsa.fromJson(Map<String, dynamic> j) => Bolsa(
        fecha: j['fecha'] as String,
        cantidadItems: (j['cantidadItems'] as num).toInt(),
        montoTotal: (j['montoTotal'] as num).toInt(),
        jornada: (j['jornada'] as String?) ?? '',
      );
}

class TotalesState extends ChangeNotifier {
  TotalesState() {
    _load();
  }

  Map<String, List<int>> clientes = {};
  Map<String, List<bool>> detalles = {};
  List<String> clienteOrden = [];
  List<String> historialClientes = [];
  String? clienteSeleccionado;
  ({String nombre, int indice})? valorSeleccionado;
  Map<String, List<Bolsa>> enviosPendientes = {};
  Map<String, int> totalesPendientes = {};
  Map<String, int> totalesCantidades = {};
  String nombreJornadaPendiente = '';
  Map<String, int> pagosRealizados = {};
  Map<String, String> notasClientes = {};
  Map<String, String> telefonosClientes = {};

  bool _hydrated = false;

  int get totalGeneral {
    var sum = 0;
    for (final vals in clientes.values) {
      for (final v in vals) {
        sum += v;
      }
    }
    return sum;
  }

  List<String> get ordenClientes {
    bool tieneActividad(String n) =>
        (clientes[n]?.isNotEmpty ?? false) ||
        totalesPendientes.containsKey(n) ||
        (enviosPendientes[n]?.isNotEmpty ?? false);

    final ordenados = clienteOrden.where(tieneActividad).toList();
    final keysClientes =
        clientes.keys.where((n) => (clientes[n]?.isNotEmpty ?? false)).toList();
    final keysTotales = totalesPendientes.keys.toList();
    final keysEnvios = enviosPendientes.keys
        .where((n) => (enviosPendientes[n]?.isNotEmpty ?? false))
        .toList();
    final todas = {...keysClientes, ...keysTotales, ...keysEnvios};
    final restantes =
        todas.where((n) => !clienteOrden.contains(n)).toList();
    return [...ordenados, ...restantes];
  }

  /// Nombres de clientes activos, para autocompletar al crear un cliente nuevo.
  List<String> get sugerenciasNuevoCliente => ordenClientes;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _restoreFromJson(data);
      }
    } catch (_) {}
    _hydrated = true;
    notifyListeners();
  }

  void _restoreFromJson(Map<String, dynamic> data) {
    clientes = _parseClientes(data['clientes']);
    detalles = _parseDetalles(data['detalles']);
    clienteOrden = (data['clienteOrden'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    historialClientes = (data['historialClientes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    enviosPendientes = _parseEnvios(data['enviosPendientes']);
    totalesPendientes = _parseTotalesPendientes(data['totalesPendientes']);
    totalesCantidades = _parseTotalesPendientes(data['totalesCantidades']);
    nombreJornadaPendiente = (data['nombreJornadaPendiente'] as String?) ?? '';
    pagosRealizados = _parseTotalesPendientes(data['pagosRealizados']);
    notasClientes = _parseNotas(data['notasClientes']);
    telefonosClientes = _parseNotas(data['telefonosClientes']);
    clienteSeleccionado = null;
    valorSeleccionado = null;
  }

  Map<String, List<int>> _parseClientes(dynamic v) {
    if (v == null) return {};
    final m = <String, List<int>>{};
    (v as Map<String, dynamic>).forEach((k, val) {
      m[k] = (val as List<dynamic>).map((e) => (e as num).toInt()).toList();
    });
    return m;
  }

  Map<String, List<bool>> _parseDetalles(dynamic v) {
    if (v == null) return {};
    final m = <String, List<bool>>{};
    (v as Map<String, dynamic>).forEach((k, val) {
      m[k] = (val as List<dynamic>).map((e) => e as bool).toList();
    });
    return m;
  }

  Map<String, List<Bolsa>> _parseEnvios(dynamic v) {
    if (v == null) return {};
    final m = <String, List<Bolsa>>{};
    (v as Map<String, dynamic>).forEach((k, val) {
      m[k] = (val as List<dynamic>)
          .map((e) => Bolsa.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    return m;
  }

  Map<String, int> _parseTotalesPendientes(dynamic v) {
    if (v == null) return {};
    final m = <String, int>{};
    (v as Map<String, dynamic>).forEach((k, val) {
      m[k] = (val as num).toInt();
    });
    return m;
  }

  Map<String, String> _parseNotas(dynamic v) {
    if (v == null) return {};
    final m = <String, String>{};
    (v as Map<String, dynamic>).forEach((k, val) {
      if (val is String && val.isNotEmpty) m[k] = val;
    });
    return m;
  }

  Future<void> _persist() async {
    if (!_hydrated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'clientes': clientes,
        'detalles': detalles,
        'clienteOrden': clienteOrden,
        'historialClientes': historialClientes,
        'totalesPendientes': totalesPendientes,
        'totalesCantidades': totalesCantidades,
        'nombreJornadaPendiente': nombreJornadaPendiente,
        'pagosRealizados': pagosRealizados,
        'notasClientes': notasClientes,
        'telefonosClientes': telefonosClientes,
        'enviosPendientes': enviosPendientes.map(
          (k, v) => MapEntry(
            k,
            v.map((b) => b.toJson()).toList(),
          ),
        ),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (_) {}
  }

  bool _clienteTieneVentasActivas(String nombre) =>
      clientes[nombre]?.isNotEmpty ?? false;

  bool _clienteTieneEnviosPendientes(String nombre) =>
      enviosPendientes[nombre]?.isNotEmpty ?? false;

  void _registrarEnHistorial(String nombre) {
    historialClientes = [nombre, ...historialClientes.where((n) => n != nombre)];
  }

  void _limpiarClienteInactivo(String nombre) {
    if (_clienteTieneVentasActivas(nombre) || _clienteTieneEnviosPendientes(nombre)) {
      return;
    }
    clientes.remove(nombre);
    detalles.remove(nombre);
    clienteOrden = clienteOrden.where((n) => n != nombre).toList();
  }

  bool agregarCliente(String nombre, int valor) {
    if (_clienteTieneVentasActivas(nombre) || _clienteTieneEnviosPendientes(nombre)) {
      return false;
    }
    clientes[nombre] = [valor];
    detalles[nombre] = [false];
    _registrarEnHistorial(nombre);
    clienteOrden = [nombre, ...clienteOrden.where((n) => n != nombre)];
    _persist();
    notifyListeners();
    return true;
  }

  void seleccionarCliente(String? nombre) {
    clienteSeleccionado = nombre;
    valorSeleccionado = null;
    notifyListeners();
  }

  void agregarValor(int valor, bool esDetalle) {
    final nombre = clienteSeleccionado;
    if (nombre == null) return;
    final existeEnClientes = clientes.containsKey(nombre);
    final existeEnEnvios = enviosPendientes.containsKey(nombre);
    if (!existeEnClientes && !existeEnEnvios) return;
    clientes[nombre] = [...(clientes[nombre] ?? []), valor];
    detalles[nombre] = [...(detalles[nombre] ?? []), esDetalle];
    clienteOrden = [nombre, ...clienteOrden.where((n) => n != nombre)];
    _persist();
    notifyListeners();
  }

  void eliminarCliente() {
    final nombre = clienteSeleccionado;
    if (nombre == null) return;
    final existeEnClientes = clientes.containsKey(nombre);
    final existeEnEnvios = enviosPendientes.containsKey(nombre);
    if (!existeEnClientes && !existeEnEnvios) return;
    clientes.remove(nombre);
    detalles.remove(nombre);
    enviosPendientes.remove(nombre);
    clienteOrden = clienteOrden.where((n) => n != nombre).toList();
    clienteSeleccionado = null;
    valorSeleccionado = null;
    _persist();
    notifyListeners();
  }

  void eliminarValorSeleccionado() {
    final vs = valorSeleccionado;
    if (vs == null) return;
    final nombre = vs.nombre;
    final indice = vs.indice;
    if (!clientes.containsKey(nombre)) return;
    final valores = [...clientes[nombre]!];
    if (indice < 0 || indice >= valores.length) return;
    valores.removeAt(indice);
    final det = <bool>[...(detalles[nombre] ?? const <bool>[])];
    if (indice < det.length) det.removeAt(indice);

    if (valores.isEmpty) {
      clientes.remove(nombre);
      detalles.remove(nombre);
      clienteOrden = clienteOrden.where((n) => n != nombre).toList();
      clienteSeleccionado = null;
      valorSeleccionado = null;
    } else {
      clientes[nombre] = valores;
      detalles[nombre] = det;
      valorSeleccionado = null;
      clienteSeleccionado = nombre;
    }
    _persist();
    notifyListeners();
  }

  void seleccionarValorTabla(String nombre, int indice) {
    valorSeleccionado = (nombre: nombre, indice: indice);
    clienteSeleccionado = nombre;
    notifyListeners();
  }

  /// Devuelve cantidad de bolsas que se generarán (clientes con ventas).
  int contarBolsasCierreJornada() {
    var c = 0;
    for (final e in clientes.entries) {
      if (e.value.isNotEmpty) c++;
    }
    return c;
  }

  Future<void> cerrarJornada() async {
    final snapshot = Map<String, List<int>>.from(
      clientes.map((k, v) => MapEntry(k, List<int>.from(v))),
    );
    syncCerrarJornada(snapshot);

    final nextClientes = Map<String, List<int>>.from(clientes);
    final nextDetalles = Map<String, List<bool>>.from(detalles);
    final nextTotales = Map<String, int>.from(totalesPendientes);
    final nextCantidades = Map<String, int>.from(totalesCantidades);

    for (final nombre in clientes.keys.toList()) {
      final valores = clientes[nombre] ?? [];
      if (valores.isEmpty) continue;
      final montoTotal = valores.fold<int>(0, (a, b) => a + b);
      nextTotales[nombre] = (nextTotales[nombre] ?? 0) + montoTotal;
      nextCantidades[nombre] = (nextCantidades[nombre] ?? 0) + valores.length;
      nextClientes.remove(nombre);
      nextDetalles.remove(nombre);
    }

    clientes = nextClientes;
    detalles = nextDetalles;
    totalesPendientes = nextTotales;
    totalesCantidades = nextCantidades;
    clienteSeleccionado = null;
    valorSeleccionado = null;
    _persist();
    notifyListeners();
  }

  void editarTotalPendiente(String nombre, int ajuste) {
    if (!totalesPendientes.containsKey(nombre)) return;
    totalesPendientes[nombre] = totalesPendientes[nombre]! + ajuste;
    _persist();
    notifyListeners();
  }

  void eliminarTotalPendiente(String nombre) {
    totalesPendientes.remove(nombre);
    totalesCantidades.remove(nombre);
    _persist();
    notifyListeners();
  }

  void cerrarTotales() {
    final fecha = DateTime.now().toIso8601String().split('T').first;
    final nextEnvios = Map<String, List<Bolsa>>.from(enviosPendientes);
    final eventosSync = <Map<String, dynamic>>[];

    for (final entry in totalesPendientes.entries) {
      final nombre = entry.key;
      final monto = entry.value;
      final cantidad = totalesCantidades[nombre] ?? 1;
      final bolsa = Bolsa(
        fecha: fecha,
        cantidadItems: cantidad,
        montoTotal: monto,
        jornada: nombreJornadaPendiente,
      );
      nextEnvios[nombre] = [...(nextEnvios[nombre] ?? []), bolsa];
      eventosSync.add({
        'estado': 'Pendiente',
        'cliente': nombre,
        'jornada': nombreJornadaPendiente,
        'paquetes': 1,
        'articulos': cantidad,
        'monto': monto,
      });
    }

    syncEnvios(eventosSync);

    totalesPendientes = {};
    totalesCantidades = {};
    nombreJornadaPendiente = '';
    enviosPendientes = nextEnvios;
    _persist();
    notifyListeners();
  }

  int get cantidadTotalesPendientes => totalesPendientes.length;

  int totalDeudaCliente(String nombre) {
    final bolsas = enviosPendientes[nombre] ?? [];
    return bolsas.fold<int>(0, (a, b) => a + b.montoTotal);
  }

  int totalPagadoCliente(String nombre) => pagosRealizados[nombre] ?? 0;

  int saldoPendienteCliente(String nombre) =>
      totalDeudaCliente(nombre) - totalPagadoCliente(nombre);

  bool clienteEstaPagado(String nombre) => saldoPendienteCliente(nombre) <= 0;

  void registrarPago(String nombre, int monto) {
    if (monto <= 0) return;
    pagosRealizados[nombre] = (pagosRealizados[nombre] ?? 0) + monto;
    syncEnvios([
      {
        'estado': 'Pagado',
        'cliente': nombre,
        'jornada': '',
        'paquetes': 0,
        'articulos': 0,
        'monto': monto,
      },
    ]);
    _persist();
    notifyListeners();
  }

  void guardarNota(String nombre, String nota) {
    if (nota.trim().isEmpty) {
      notasClientes.remove(nombre);
    } else {
      notasClientes[nombre] = nota.trim();
    }
    _persist();
    notifyListeners();
  }

  /// Retorna null si se guardó correctamente, o el nombre del cliente
  /// que ya tiene ese número si está duplicado.
  String? guardarTelefono(String nombre, String telefono) {
    if (telefono.trim().isEmpty) {
      telefonosClientes.remove(nombre);
      _persist();
      notifyListeners();
      return null;
    }
    final num = telefono.trim();
    for (final entry in telefonosClientes.entries) {
      if (entry.key != nombre && entry.value == num) {
        return entry.key;
      }
    }
    telefonosClientes[nombre] = num;
    _persist();
    notifyListeners();
    return null;
  }

  void despachar(String nombre, {List<int>? indices}) {
    if (!enviosPendientes.containsKey(nombre)) return;
    final bolsas = enviosPendientes[nombre]!;
    final despacharTodos = indices == null ||
        indices.isEmpty ||
        indices.length >= bolsas.length;
    final set = despacharTodos
        ? bolsas.asMap().keys.toSet()
        : indices.toSet();
    final eventosSync = <Map<String, dynamic>>[];

    for (var i = 0; i < bolsas.length; i++) {
      if (!set.contains(i)) continue;
      final bolsa = bolsas[i];
      eventosSync.add({
        'estado': 'Despachado',
        'cliente': nombre,
        'jornada': bolsa.jornada,
        'paquetes': 1,
        'articulos': bolsa.cantidadItems,
        'monto': bolsa.montoTotal,
      });
    }

    syncEnvios(eventosSync);

    if (despacharTodos) {
      enviosPendientes.remove(nombre);
      pagosRealizados.remove(nombre);
      notasClientes.remove(nombre);
    } else {
      final remaining = <Bolsa>[];
      for (var i = 0; i < bolsas.length; i++) {
        if (!set.contains(i)) remaining.add(bolsas[i]);
      }
      if (remaining.isEmpty) {
        enviosPendientes.remove(nombre);
        pagosRealizados.remove(nombre);
        notasClientes.remove(nombre);
      } else {
        enviosPendientes[nombre] = remaining;
      }
    }
    _limpiarClienteInactivo(nombre);
    _persist();
    notifyListeners();
  }

  void reiniciarTodo() {
    clientes = {};
    detalles = {};
    clienteOrden = [];
    historialClientes = [];
    totalesPendientes = {};
    enviosPendientes = {};
    clienteSeleccionado = null;
    valorSeleccionado = null;
    _persist();
    notifyListeners();
  }
}
