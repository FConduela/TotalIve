import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import '../utils/format_money.dart';

class TotalesScreen extends StatefulWidget {
  const TotalesScreen({
    super.key,
    required this.onCerrarTotales,
  });

  final VoidCallback onCerrarTotales;

  @override
  State<TotalesScreen> createState() => _TotalesScreenState();
}

class _TotalesScreenState extends State<TotalesScreen> {
  String? _clienteAEliminar;
  final _buscarController = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TotalesState>();
    final todosNombres = state.totalesPendientes.keys.toList();
    final nombres = _filtro.isEmpty
        ? todosNombres
        : todosNombres
            .where((n) => n.toLowerCase().contains(_filtro.toLowerCase()))
            .toList();
    final totalGlobal = state.totalesPendientes.values.fold<int>(0, (a, b) => a + b);
    final totalCantidad = state.totalesCantidades.values.fold<int>(0, (a, b) => a + b);

    if (todosNombres.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _resumenCards(0, 0, 0),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'Sin totales pendientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Usa "Cerrar Jornada" en Inicio para acumular totales.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.nombreJornadaPendiente.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      state.nombreJornadaPendiente,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                _resumenCards(todosNombres.length, totalCantidad, totalGlobal),
                const SizedBox(height: 12),
                TextField(
                  controller: _buscarController,
                  onChanged: (v) => setState(() => _filtro = v.trim()),
                  style: const TextStyle(color: AppColors.text, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Buscar cliente...',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                    suffixIcon: _filtro.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 20),
                            onPressed: () {
                              _buscarController.clear();
                              setState(() => _filtro = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.input,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    primary: false,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: nombres.length,
                    itemBuilder: (context, index) {
                      final nombre = nombres[index];
                      final monto = state.totalesPendientes[nombre] ?? 0;
                      return _TotalClienteCard(
                        nombre: nombre,
                        monto: monto,
                        onEliminar: () => setState(() => _clienteAEliminar = nombre),
                      );
                    },
                  ),
                ),
                FilledButton.icon(
                  onPressed: widget.onCerrarTotales,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Cerrar Totales',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_clienteAEliminar != null) _buildConfirmarEliminar(),
      ],
    );
  }

  Widget _buildConfirmarEliminar() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _clienteAEliminar = null),
        child: ColoredBox(
          color: Colors.black54,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x4D2A6BA0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '¿Eliminar a "$_clienteAEliminar"?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Se eliminará este cliente de los totales pendientes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _clienteAEliminar = null),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                context.read<TotalesState>().eliminarTotalPendiente(_clienteAEliminar!);
                                setState(() => _clienteAEliminar = null);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
      ),
    );
  }

  Widget _resumenCards(int numClientes, int totalCantidad, int totalGlobal) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x4D2A6BA0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$numClientes',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Clientes',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x4D2A6BA0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalCantidad',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Productos',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x4D2A6BA0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatMoney(totalGlobal),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalClienteCard extends StatefulWidget {
  const _TotalClienteCard({
    required this.nombre,
    required this.monto,
    required this.onEliminar,
  });

  final String nombre;
  final int monto;
  final VoidCallback onEliminar;

  @override
  State<_TotalClienteCard> createState() => _TotalClienteCardState();
}

class _TotalClienteCardState extends State<_TotalClienteCard> {
  bool _editando = false;
  bool _editandoTelefono = false;
  String? _errorTelefono;
  final _ajusteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _ajusteController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _aplicarAjuste(bool esSuma) {
    final valor = int.tryParse(_ajusteController.text.trim());
    if (valor == null || valor == 0) return;
    final ajuste = esSuma ? valor : -valor;
    context.read<TotalesState>().editarTotalPendiente(widget.nombre, ajuste);
    _ajusteController.clear();
    setState(() => _editando = false);
  }

  @override
  Widget build(BuildContext context) {
    final telefono = context.watch<TotalesState>().telefonosClientes[widget.nombre];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x4D2A6BA0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    formatMoney(widget.monto),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onEliminar,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: AppColors.danger, size: 22),
                    ),
                  ),
                ],
              ),
              if (telefono != null && telefono.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      telefono,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () async {
                          await _picker.pickImage(source: ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Foto',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => setState(() {
                          _editando = !_editando;
                          if (_editando) _editandoTelefono = false;
                        }),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Editar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => setState(() {
                          _editandoTelefono = !_editandoTelefono;
                          if (_editandoTelefono) {
                            _editando = false;
                            var current = context.read<TotalesState>().telefonosClientes[widget.nombre] ?? '';
                            if (current.startsWith('+569')) {
                              current = current.substring(4);
                            }
                            _telefonoController.text = current;
                          }
                        }),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Teléfono',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_editando) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ajusteController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.text, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Monto...',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.input,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _aplicarAjuste(true),
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.add, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _aplicarAjuste(false),
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.remove, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_editandoTelefono) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      '+569',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        maxLength: 8,
                        style: const TextStyle(color: AppColors.text, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: '12345678',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.input,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          final numero = _telefonoController.text.trim();
                          final telefonoCompleto = numero.isNotEmpty ? '+569$numero' : '';
                          final duplicado = context.read<TotalesState>().guardarTelefono(
                            widget.nombre,
                            telefonoCompleto,
                          );
                          if (duplicado != null) {
                            setState(() => _errorTelefono = duplicado);
                            return;
                          }
                          setState(() {
                            _editandoTelefono = false;
                            _errorTelefono = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.check, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_errorTelefono != null) ...[
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ese número ya está asignado a $_errorTelefono',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _errorTelefono = null),
                            child: const Icon(Icons.close, color: AppColors.danger, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
