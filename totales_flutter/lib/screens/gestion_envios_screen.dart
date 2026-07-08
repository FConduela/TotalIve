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
  String _filtro = '';

  @override
  void dispose() {
    _buscarController.dispose();
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
                  Expanded(child: _resumenCard('0', 'Total Bolsas Pendientes')),
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
                        'Usa "Cerrar Jornada" en Inicio para acumular bolsas.',
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: _resumenCard('$totalBolsas', 'Total Bolsas Pendientes')),
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
                                  '$totalBolsasCliente Bolsa${totalBolsasCliente != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
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
                            FilledButton.icon(
                              onPressed: ningunoSeleccionado
                                  ? null
                                  : () => widget.onMarcarComoEnviado(nombre, enviarIndices),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success,
                                disabledBackgroundColor:
                                    AppColors.success.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                              label: Text(
                                (todasSeleccionadas || seleccion == null)
                                    ? 'Marcar como Enviado'
                                    : 'Marcar ${indicesSeleccionados.length} como enviada${indicesSeleccionados.length != 1 ? 's' : ''}',
                                style: const TextStyle(
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
                  );
                },
              ),
            ),
          ],
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
                  child: Text(
                    bolsa.fecha,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
