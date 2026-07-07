import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../theme.dart';
import '../utils/format_money.dart';

const int _maxColumnas = 100;

class TablaScreen extends StatelessWidget {
  const TablaScreen({super.key, required this.onAbrirEliminarValor});

  final VoidCallback onAbrirEliminarValor;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TotalesState>();
    final nombres = state.ordenClientes;
    final maxValores = nombres.isEmpty
        ? 1
        : nombres
            .map((n) => (state.clientes[n] ?? const <int>[]).length)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, _maxColumnas);

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tabla de Clientes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: FilledButton(
                    onPressed: onAbrirEliminarValor,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            const SizedBox(height: 14),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x592A6BA0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      primary: false,
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
                                _th('Nombre'),
                                for (var i = 0; i < maxValores; i++) _th('V${i + 1}'),
                                _th('Total'),
                              ],
                            ),
                            for (var rowIndex = 0; rowIndex < nombres.length; rowIndex++)
                              _buildRow(context, state, nombres[rowIndex], rowIndex, maxValores),
                          ],
                        ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(
    BuildContext context,
    TotalesState state,
    String nombre,
    int rowIndex,
    int maxValores,
  ) {
    final valores = state.clientes[nombre] ?? const <int>[];
    final detalles = state.detalles[nombre] ?? const <bool>[];
    final total = valores.fold<int>(0, (a, b) => a + b);
    final valorSel = state.valorSeleccionado;
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
        TableCell(
          child: Padding(
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
        ),
        for (var i = 0; i < maxValores; i++)
          _celdaValor(context, state, nombre, i, valores, detalles, valorSel),
        TableCell(
          child: DecoratedBox(
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
        ),
      ],
    );
  }

  Widget _th(String t) {
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

  TableCell _celdaValor(
    BuildContext context,
    TotalesState state,
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

    return TableCell(
      child: Material(
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
      ),
    );
  }
}
