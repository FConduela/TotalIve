import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import '../utils/format_money.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onAbrirNuevoCliente,
    required this.onAbrirValores,
    required this.onCerrarJornada,
  });

  final VoidCallback onAbrirNuevoCliente;
  final void Function(String nombre) onAbrirValores;
  final VoidCallback onCerrarJornada;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TotalesState>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x4D2A6BA0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Material(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: onAbrirNuevoCliente,
                        borderRadius: BorderRadius.circular(8),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.person_add, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Clientes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44, height: 44),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    primary: false,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: state.ordenClientes.length,
                    itemBuilder: (context, i) {
                      final nombre = state.ordenClientes[i];
                      final valores = state.clientes[nombre] ?? const <int>[];
                      final total = valores.fold<int>(0, (a, b) => a + b);
                      final selected = state.clienteSeleccionado == nombre;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: selected
                              ? const Color(0x404CAF50)
                              : AppColors.input,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => onAbrirValores(nombre),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15, color: AppColors.text),
                                    ),
                                  ),
                                  Text(
                                    'Total: ${formatMoney(total)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cantidad: ${valores.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(color: Color(0x332A6BA0), height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.totalBadge,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: _TotalGeneralText(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: onCerrarJornada,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Text(
                            'Cerrar Jornada',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
    );
  }
}

class _TotalGeneralText extends StatelessWidget {
  const _TotalGeneralText();

  @override
  Widget build(BuildContext context) {
    final total = context.select<TotalesState, int>((s) => s.totalGeneral);
    return Text(
      'Total General: ${formatMoney(total)}',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}
