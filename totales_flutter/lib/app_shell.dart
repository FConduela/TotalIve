import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/gestion_envios_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tabla_screen.dart';
import 'theme.dart';
import 'utils/format_money.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  bool _modalNuevoCliente = false;
  bool _modalValores = false;
  bool _modalTabla = false;
  bool _modalEliminarCliente = false;
  bool _modalEliminarValor = false;
  bool _modalCerrarJornada = false;
  bool _modalCerrarTotales = false;
  ({String nombre, List<int>? indices})? _despacharConfirmar;

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showValoresDialog(String nombre) async {
    final state = context.read<TotalesState>();
    state.seleccionarCliente(nombre);
    setState(() => _modalValores = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TotalesState>();

    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _tab,
            children: [
              HomeScreen(
                onAbrirNuevoCliente: () => setState(() => _modalNuevoCliente = true),
                onAbrirValores: _showValoresDialog,
                onCerrarJornada: () => setState(() => _modalCerrarJornada = true),
                onAbrirTabla: () => setState(() => _modalTabla = true),
              ),
              TotalesScreen(
                onCerrarTotales: () => setState(() => _modalCerrarTotales = true),
              ),
              GestionEnviosScreen(
                onMarcarComoEnviado: (nombre, indices) {
                  setState(() => _despacharConfirmar = (nombre: nombre, indices: indices));
                },
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Totales',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Envíos',
              ),
            ],
          ),
        ),
        if (_modalTabla) _buildOverlayTabla(),
        if (_modalNuevoCliente) _buildOverlayNuevoCliente(),
        if (_modalValores) _buildOverlayValores(),
        if (_modalEliminarCliente) _buildOverlayConfirmar(
          titulo: state.clienteSeleccionado != null
              ? '¿Desea eliminar a ${state.clienteSeleccionado}?'
              : '',
          onCancelar: () => setState(() => _modalEliminarCliente = false),
          onConfirmar: () {
            context.read<TotalesState>().eliminarCliente();
            setState(() => _modalEliminarCliente = false);
            _toast('✓ Cliente eliminado');
          },
        ),
        if (_modalEliminarValor)
          _buildOverlayConfirmar(
            titulo: '¿Seguro que desea eliminar el valor?',
            onCancelar: () => setState(() => _modalEliminarValor = false),
            onConfirmar: () {
              context.read<TotalesState>().eliminarValorSeleccionado();
              setState(() => _modalEliminarValor = false);
              _toast('✓ Valor eliminado');
            },
          ),
        if (_modalCerrarJornada)
          _buildOverlayConfirmar(
            titulo:
                'Se generarán bolsas con las ventas actuales y se limpiarán los contadores del día. ¿Continuar?',
            onCancelar: () => setState(() => _modalCerrarJornada = false),
            onConfirmar: () async {
              final st = context.read<TotalesState>();
              final cantidadBolsas = st.contarBolsasCierreJornada();
              await st.cerrarJornada();
              if (!mounted) return;
              setState(() => _modalCerrarJornada = false);
              _toast(
                cantidadBolsas > 0
                    ? 'Se generaron $cantidadBolsas bolsa${cantidadBolsas != 1 ? 's' : ''}'
                    : 'Jornada cerrada',
              );
            },
          ),
        if (_modalCerrarTotales)
          _buildOverlayConfirmar(
            titulo:
                'Se enviarán los totales pendientes a la pantalla de envíos. ¿Continuar?',
            onCancelar: () => setState(() => _modalCerrarTotales = false),
            onConfirmar: () {
              final st = context.read<TotalesState>();
              final cantidad = st.cantidadTotalesPendientes;
              st.cerrarTotales();
              setState(() => _modalCerrarTotales = false);
              _toast(
                cantidad > 0
                    ? '$cantidad cliente${cantidad != 1 ? 's' : ''} enviado${cantidad != 1 ? 's' : ''} a envíos'
                    : 'Sin totales que cerrar',
              );
            },
          ),
        if (_despacharConfirmar != null)
          _buildOverlayConfirmar(
            titulo: _tituloDespachar(_despacharConfirmar!),
            onCancelar: () => setState(() => _despacharConfirmar = null),
            onConfirmar: () {
              final d = _despacharConfirmar!;
              context.read<TotalesState>().despachar(d.nombre, indices: d.indices);
              setState(() => _despacharConfirmar = null);
              _toast('Envío marcado como realizado');
            },
          ),
      ],
    );
  }

  String _tituloDespachar(({String nombre, List<int>? indices}) d) {
    final idx = d.indices;
    if (idx == null || idx.isEmpty) {
      return '¿Marcar todas las bolsas de ${d.nombre} como enviadas?';
    }
    return '¿Marcar ${idx.length} bolsa(s) de ${d.nombre} como enviadas?';
  }

  Widget _buildOverlayConfirmar({
    required String titulo,
    required VoidCallback onCancelar,
    required VoidCallback onConfirmar,
  }) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _roundIconBtn(
                          color: AppColors.danger,
                          icon: Icons.close,
                          onPressed: onCancelar,
                        ),
                        const SizedBox(width: 16),
                        _roundIconBtn(
                          color: AppColors.success,
                          icon: Icons.check,
                          onPressed: onConfirmar,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roundIconBtn({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildOverlayTabla() {
    final state = context.watch<TotalesState>();
    final vs = state.valorSeleccionado;
    String textoEliminar = 'Eliminar Valor';
    if (vs != null) {
      final nombre = vs.nombre;
      final indice = vs.indice;
      final vals = state.clientes[nombre];
      if (vals != null && indice >= 0 && indice < vals.length) {
        textoEliminar = 'Eliminar ${formatMoney(vals[indice])} ($nombre)';
      }
    }

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x592A6BA0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tabla de Clientes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      Material(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => setState(() => _modalTabla = false),
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: Text(
                                '✕',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _TablaModalContent()),
                  const SizedBox(height: 10),
                  Center(
                    child: FilledButton(
                      onPressed: () {
                        if (state.valorSeleccionado != null) {
                          setState(() => _modalEliminarValor = true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        textoEliminar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayNuevoCliente() {
    final sugerencias = context.watch<TotalesState>().sugerenciasNuevoCliente;
    return _NuevoClienteOverlay(
      sugerencias: sugerencias,
      onClose: () => setState(() => _modalNuevoCliente = false),
      onAgregar: (nombre, valor) {
        final agregado = context.read<TotalesState>().agregarCliente(nombre, valor);
        if (agregado) {
          setState(() => _modalNuevoCliente = false);
        }
        return agregado;
      },
    );
  }

  Widget _buildOverlayValores() {
    final nombre = context.watch<TotalesState>().clienteSeleccionado ?? '';
    return _ValoresOverlay(
      nombreCliente: nombre,
      onClose: () => setState(() => _modalValores = false),
      onEliminarCliente: () {
        setState(() {
          _modalValores = false;
          _modalEliminarCliente = true;
        });
      },
      onAgregarValor: (valor, esDetalle) {
        context.read<TotalesState>().agregarValor(valor, esDetalle);
        setState(() => _modalValores = false);
        _toast('Valor agregado: ${formatMoney(valor)}');
      },
    );
  }
}

class _NuevoClienteOverlay extends StatefulWidget {
  const _NuevoClienteOverlay({
    required this.sugerencias,
    required this.onClose,
    required this.onAgregar,
  });

  final List<String> sugerencias;
  final VoidCallback onClose;
  final bool Function(String nombre, int valor) onAgregar;

  @override
  State<_NuevoClienteOverlay> createState() => _NuevoClienteOverlayState();
}

class _NuevoClienteOverlayState extends State<_NuevoClienteOverlay> {
  static const _alturaItemSugerencia = 44.0;
  static const _maxSugerencias = 6;

  final _nombre = TextEditingController();
  final _valor = TextEditingController();
  String? _errorCliente;

  List<String> get _sugerenciasFiltradas {
    final query = _nombre.text;
    if (query.isEmpty) return const [];
    final queryNorm = _normalizarTexto(query);
    return widget.sugerencias
        .where((n) {
          final nombreNorm = _normalizarTexto(n);
          return nombreNorm.startsWith(queryNorm) && nombreNorm != queryNorm;
        })
        .take(_maxSugerencias)
        .toList();
  }

  double get _alturaBarraSugerencias =>
      _sugerenciasFiltradas.length * _alturaItemSugerencia;

  String _normalizarTexto(String text) {
    const conAcento = 'áéíóúüñàèìòùâêîôûäëïöü';
    const sinAcento = 'aeiouunaeiouaeiouaeiou';
    var result = text.toLowerCase();
    for (var i = 0; i < conAcento.length; i++) {
      result = result.replaceAll(conAcento[i], sinAcento[i]);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _nombre.addListener(() {
      setState(() => _errorCliente = null);
    });
  }

  @override
  void dispose() {
    _nombre.dispose();
    _valor.dispose();
    super.dispose();
  }

  void _agregar() {
    final n = _nombre.text.trim();
    final v = int.tryParse(_valor.text.trim());
    if (n.isEmpty || v == null) return;
    final agregado = widget.onAgregar(n, v);
    if (!agregado) {
      setState(() => _errorCliente = 'El cliente ingresado ya existe');
      return;
    }
    _nombre.clear();
    _valor.clear();
    _errorCliente = null;
  }

  Widget _buildBarraSugerencias() {
    final items = _sugerenciasFiltradas;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.input,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: _alturaBarraSugerencias,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox(
                    height: _alturaItemSugerencia,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: i < items.length - 1
                            ? const Border(
                                bottom: BorderSide(color: Color(0x332A6BA0)),
                              )
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final nombre = items[i];
                            _nombre.text = nombre;
                            _nombre.selection = TextSelection.collapsed(
                              offset: nombre.length,
                            );
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                items[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Nuevo Cliente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        _roundClose(widget.onClose),
                      ],
                    ),
                    const Divider(color: Color(0x662A6BA0)),
                    const Text(
                      'Nombre del Cliente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nombre,
                      style: const TextStyle(color: AppColors.text, fontSize: 16),
                      decoration: _inputDeco('Ingresa el nombre...'),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                    ),
                    _buildBarraSugerencias(),
                    const SizedBox(height: 14),
                    const Text(
                      'Valor Inicial',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _valor,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text, fontSize: 16),
                      decoration: _inputDeco('Valor...'),
                    ),
                    if (_errorCliente != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorCliente!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _agregar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '+ Agregar Cliente',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  Widget _roundClose(VoidCallback onPressed) {
    return Material(
      color: AppColors.danger,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text('✕', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _ValoresOverlay extends StatefulWidget {
  const _ValoresOverlay({
    required this.nombreCliente,
    required this.onClose,
    required this.onEliminarCliente,
    required this.onAgregarValor,
  });

  final String nombreCliente;
  final VoidCallback onClose;
  final VoidCallback onEliminarCliente;
  final void Function(int valor, bool esDetalle) onAgregarValor;

  @override
  State<_ValoresOverlay> createState() => _ValoresOverlayState();
}

class _ValoresOverlayState extends State<_ValoresOverlay> {
  bool _detalle = false;
  final _otro = TextEditingController();

  @override
  void dispose() {
    _otro.dispose();
    super.dispose();
  }

  void _agregar(int valor) {
    widget.onAgregarValor(valor, _detalle);
    setState(() => _detalle = false);
  }

  void _agregarOtro() {
    final v = int.tryParse(_otro.text.trim());
    if (v == null) return;
    _agregar(v);
    _otro.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: widget.onEliminarCliente,
                            borderRadius: BorderRadius.circular(8),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.delete_outline, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.nombreCliente,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Material(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: widget.onClose,
                            borderRadius: BorderRadius.circular(8),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: Text(
                                  '✕',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0x662A6BA0)),
                    Row(
                      children: [
                        const Text(
                          'Detalle:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text),
                        ),
                        const Spacer(),
                        Switch(
                          value: _detalle,
                          onChanged: (v) => setState(() => _detalle = v),
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 360,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 3.4,
                        children: valoresBotones
                            .map(
                              (v) => FilledButton(
                                onPressed: () => _agregar(v),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  '$v',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _otro,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.text, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Otro valor',
                              hintStyle: const TextStyle(color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.input,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 50,
                          height: 48,
                          child: FilledButton(
                            onPressed: _agregarOtro,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const int _maxColumnasModal = 100;

class _TablaModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<TotalesState>();
    final nombres = state.ordenClientes;
    final maxValores = nombres.isEmpty
        ? 1
        : nombres
            .map((n) => (state.clientes[n] ?? const <int>[]).length)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, _maxColumnasModal);
    final valorSel = state.valorSeleccionado;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: const FixedColumnWidth(120),
              for (var c = 1; c <= maxValores; c++) c: const FixedColumnWidth(76),
              maxValores + 1: const FixedColumnWidth(92),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.primary),
                children: [
                  _tablaHeader('Nombre'),
                  for (var i = 0; i < maxValores; i++) _tablaHeader('V${i + 1}'),
                  _tablaHeader('Total'),
                ],
              ),
              for (var rowIndex = 0; rowIndex < nombres.length; rowIndex++)
                _buildTablaRow(context, state, nombres[rowIndex], rowIndex, maxValores, valorSel),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _tablaHeader(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        t,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  static TableRow _buildTablaRow(
    BuildContext context,
    TotalesState state,
    String nombre,
    int rowIndex,
    int maxValores,
    ({String nombre, int indice})? valorSel,
  ) {
    final valores = state.clientes[nombre] ?? const <int>[];
    final detalles = state.detalles[nombre] ?? const <bool>[];
    final total = valores.fold<int>(0, (a, b) => a + b);
    final filaSelected = valorSel != null && valorSel.nombre == nombre;
    final esPar = rowIndex.isEven;
    final bg = filaSelected
        ? const Color(0x384CAF50)
        : (esPar ? const Color(0x992B2B2B) : const Color(0xCC212121));

    return TableRow(
      decoration: BoxDecoration(
        color: bg,
        border: const Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (var i = 0; i < maxValores; i++)
          _celdaValorModal(context, nombre, i, valores, detalles, valorSel),
        DecoratedBox(
          decoration: const BoxDecoration(color: Color(0x2E2196F3)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Text(
              formatMoney(total),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _celdaValorModal(
    BuildContext context,
    String nombre,
    int i,
    List<int> valores,
    List<bool> detalles,
    ({String nombre, int indice})? valorSel,
  ) {
    final val = i < valores.length ? valores[i] : null;
    final esDetalle = i < detalles.length && detalles[i];
    final celdaSelected =
        valorSel != null && valorSel.nombre == nombre && valorSel.indice == i;

    return Material(
      color: celdaSelected ? const Color(0x804CAF50) : Colors.transparent,
      child: InkWell(
        onTap: val != null
            ? () => context.read<TotalesState>().seleccionarValorTabla(nombre, i)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              val == null
                  ? ''
                  : (esDetalle ? '(${formatMoney(val)})' : formatMoney(val)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: esDetalle ? AppColors.textMuted : AppColors.text,
                fontSize: 13,
                fontStyle: esDetalle ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ),
    );
  }
}
