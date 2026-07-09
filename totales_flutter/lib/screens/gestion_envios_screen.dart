import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import '../utils/format_money.dart';

class GestionEnviosScreen extends StatefulWidget {
  const GestionEnviosScreen({super.key, required this.onMarcarComoEnviado});

  final void Function(String nombre, List<int>? indices) onMarcarComoEnviado;

  @override
  State<GestionEnviosScreen> createState() => _GestionEnviosScreenState();
}

class _GestionEnviosScreenState extends State<GestionEnviosScreen> {
  final Map<String, List<int>> _seleccionados = {};
  final _buscarController = TextEditingController();
  final _pagoController = TextEditingController();
  final _notaController = TextEditingController();
  String _filtro = '';
  String? _clientePagando;
  String? _clienteNota;

  @override
  void dispose() {
    _buscarController.dispose();
    _pagoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  void _toggleBolsa(String nombre, int idx, int totalBolsas) {
    setState(() {
      final actual = List<int>.from(_seleccionados[nombre] ?? List.generate(totalBolsas, (i) => i));
      final set = actual.toSet();
      if (set.contains(idx)) {
        set.remove(idx);
      } else {
        set.add(idx);
      }
      _seleccionados[nombre] = set.toList()..sort();
    });
  }

  void _marcarTodasBolsas(String nombre, int totalBolsas) {
    setState(() {
      _seleccionados[nombre] = List.generate(totalBolsas, (i) => i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TotalesState>();
    final envios = state.enviosPendientes;
    final clientesConEnvios = envios.keys.where((n) => (envios[n]?.isNotEmpty ?? false)).toList();

    final totalBolsas = clientesConEnvios.fold<int>(0, (a, n) => a + (envios[n]?.length ?? 0));
    final totalProductos = clientesConEnvios.fold<int>(0, (acc, nombre) {
      final bolsas = envios[nombre] ?? const <Bolsa>[];
      return acc + bolsas.fold<int>(0, (s, b) => s + b.cantidadItems);
    });

    final clientesFiltrados = _filtro.isEmpty
        ? clientesConEnvios
        : clientesConEnvios
            .where((n) => n.toLowerCase().contains(_filtro.toLowerCase()))
            .toList();

    if (clientesConEnvios.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _resumenCard('0', 'Total Pedidos Pendientes')),
                  const SizedBox(width: 12),
                  Expanded(child: _resumenCard('0', 'Total Productos')),
                ],
              ),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'Sin envíos pendientes',
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
                        'Usa "Cerrar Jornada" en Inicio para acumular Pedidos.',
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
                Row(
                  children: [
                    Expanded(child: _resumenCard('$totalBolsas', 'Total Pedidos Pendientes')),
                    const SizedBox(width: 12),
                    Expanded(child: _resumenCard('$totalProductos', 'Total Productos')),
                  ],
                ),
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
                const SizedBox(height: 16),
                const Text(
                  'Lista de pendientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    primary: false,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: clientesFiltrados.length,
                itemBuilder: (context, index) {
                  final nombre = clientesFiltrados[index];
                  final bolsas = envios[nombre] ?? const <Bolsa>[];
                  final totalBolsasCliente = bolsas.length;
                  final seleccion = _seleccionados[nombre];
                  final indicesSeleccionados =
                      seleccion ?? List.generate(totalBolsasCliente, (i) => i);
                  final ningunoSeleccionado = indicesSeleccionados.isEmpty;
                  final todasSeleccionadas = indicesSeleccionados.length == totalBolsasCliente;
                  final enviarIndices =
                      (todasSeleccionadas || seleccion == null) ? null : indicesSeleccionados;

                  final estaPagado = state.clienteEstaPagado(nombre);
                  final saldoPendiente = state.saldoPendienteCliente(nombre);
                  final totalPagado = state.totalPagadoCliente(nombre);
                  final totalDeuda = state.totalDeudaCliente(nombre);

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
                              children: [
                                Expanded(
                                  child: Text(
                                    nombre,
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
                                  '$totalBolsasCliente Pedido${totalBolsasCliente != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            if (state.telefonosClientes[nombre] != null &&
                                state.telefonosClientes[nombre]!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 13, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.telefonosClientes[nombre]!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Total: ${formatMoney(totalDeuda)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (totalPagado > 0)
                                  Text(
                                    'Pagado: ${formatMoney(totalPagado)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (saldoPendiente > 0 && totalPagado > 0) ...[
                                  const SizedBox(width: 12),
                                  Text(
                                    'Debe: ${formatMoney(saldoPendiente)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    _notaController.text = state.notasClientes[nombre] ?? '';
                                    setState(() => _clienteNota = nombre);
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.note_add, color: AppColors.primary, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            if (state.notasClientes.containsKey(nombre))
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  state.notasClientes[nombre]!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _marcarTodasBolsas(nombre, totalBolsasCliente),
                              child: const Text(
                                'Seleccionar todas',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (var i = 0; i < bolsas.length; i++)
                              _bolsaRow(
                                bolsa: bolsas[i],
                                checked: seleccion == null || indicesSeleccionados.contains(i),
                                onTap: () => _toggleBolsa(nombre, i, totalBolsasCliente),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => setState(() => _clientePagando = nombre),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: estaPagado
                                          ? AppColors.success
                                          : AppColors.warning,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: Icon(
                                      estaPagado ? Icons.check_circle : Icons.payment,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    label: Text(
                                      estaPagado ? 'Pagado' : 'Pagar',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: (ningunoSeleccionado || !estaPagado)
                                        ? null
                                        : () => widget.onMarcarComoEnviado(nombre, enviarIndices),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      disabledBackgroundColor:
                                          AppColors.primary.withValues(alpha: 0.3),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                                    label: const Text(
                                      'Despachar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
    if (_clientePagando != null) _buildModalPago(state),
    if (_clienteNota != null) _buildModalNota(state),
      ],
    );
  }

  Widget _buildModalPago(TotalesState state) {
    final nombre = _clientePagando!;
    final saldo = state.saldoPendienteCliente(nombre);
    final bolsas = state.enviosPendientes[nombre] ?? const <Bolsa>[];
    final seleccion = _seleccionados[nombre];
    final indicesSeleccionados = seleccion ?? List.generate(bolsas.length, (i) => i);

    final montoSeleccionado = indicesSeleccionados.fold<int>(0, (acc, i) {
      if (i < bolsas.length) return acc + bolsas[i].montoTotal;
      return acc;
    });

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() {
          _clientePagando = null;
          _pagoController.clear();
        }),
        child: Material(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Pago - $nombre',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _clientePagando = null;
                                    _pagoController.clear();
                                  }),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close, color: AppColors.textMuted, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Saldo pendiente: ${formatMoney(saldo > 0 ? saldo : 0)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (indicesSeleccionados.length < bolsas.length) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Seleccionado: ${formatMoney(montoSeleccionado)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pagoController,
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
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () {
                                final montoBase = (indicesSeleccionados.length < bolsas.length && montoSeleccionado > 0)
                                    ? montoSeleccionado
                                    : saldo;
                                final monto = montoBase > saldo ? saldo : montoBase;
                                _pagoController.text = monto > 0 ? monto.toString() : '0';
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              child: const Text(
                                'Pagar Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            final monto = int.tryParse(_pagoController.text.trim());
                            if (monto == null || monto <= 0) return;
                            state.registrarPago(nombre, monto);
                            _pagoController.clear();
                            setState(() => _clientePagando = null);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Confirmar Pago',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
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
        ),
      ),
    );
  }

  Widget _buildModalNota(TotalesState state) {
    final nombre = _clienteNota!;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() {
          _clienteNota = null;
          _notaController.clear();
        }),
        child: Material(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(child: SizedBox()),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Nota - $nombre',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _clienteNota = null;
                                    _notaController.clear();
                                  }),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close, color: AppColors.textMuted, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notaController,
                          maxLines: 3,
                          style: const TextStyle(color: AppColors.text, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Escribe una nota...',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.input,
                            contentPadding: const EdgeInsets.all(12),
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
                        FilledButton(
                          onPressed: () {
                            state.guardarNota(nombre, _notaController.text);
                            _notaController.clear();
                            setState(() => _clienteNota = null);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Guardar Nota',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
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
        ),
      ),
    );
  }

  Widget _resumenCard(String valor, String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x4D2A6BA0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bolsaRow({
    required Bolsa bolsa,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: AppColors.input,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: checked ? const Color(0x804CAF50) : Colors.transparent,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: checked ? AppColors.success : AppColors.textMuted,
                      width: 2,
                    ),
                    color: checked ? AppColors.success : Colors.transparent,
                  ),
                  child: checked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bolsa.jornada.isNotEmpty)
                        Text(
                          bolsa.jornada,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        bolsa.fecha,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'art. ${bolsa.cantidadItems}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  formatMoney(bolsa.montoTotal),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
