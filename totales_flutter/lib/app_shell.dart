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
  bool _modalEliminarCliente = false;
  bool _modalEliminarValor = false;
  bool _modalCerrarJornada = false;
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
              ),
              TablaScreen(
                onAbrirEliminarValor: () {
                  if (state.valorSeleccionado != null) {
                    setState(() => _modalEliminarValor = true);
                  }
                },
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
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view),
                label: 'Tabla',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Envíos',
              ),
            ],
          ),
        ),
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

  Widget _buildOverlayNuevoCliente() {
    return _NuevoClienteOverlay(
      onClose: () => setState(() => _modalNuevoCliente = false),
      onAgregar: (nombre, valor) {
        context.read<TotalesState>().agregarCliente(nombre, valor);
        setState(() => _modalNuevoCliente = false);
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
        _toast('Valor agregado: ${formatMoney(valor)}');
      },
    );
  }
}

class _NuevoClienteOverlay extends StatefulWidget {
  const _NuevoClienteOverlay({
    required this.onClose,
    required this.onAgregar,
  });

  final VoidCallback onClose;
  final void Function(String nombre, int valor) onAgregar;

  @override
  State<_NuevoClienteOverlay> createState() => _NuevoClienteOverlayState();
}

class _NuevoClienteOverlayState extends State<_NuevoClienteOverlay> {
  final _nombre = TextEditingController();
  final _valor = TextEditingController();

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
    widget.onAgregar(n, v);
    _nombre.clear();
    _valor.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    ),
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
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _agregar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        '+ Agregar Cliente',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                        physics: const NeverScrollableScrollPhysics(),
                        children: valoresBotones
                            .map(
                              (v) => FilledButton(
                                onPressed: () => _agregar(v),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  '$v',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
