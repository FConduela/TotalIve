import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { useApp } from '../context/AppContext';
import { formatMoney } from '../utils/formatMoney';
import { colors } from '../theme';

const MAX_COLUMNAS = 100;

export function TablaScreen({ onAbrirEliminarValor }) {
  const { state, dispatch, ordenClientes } = useApp();
  const nombres = ordenClientes;
  const maxValores = nombres.length
    ? Math.min(MAX_COLUMNAS, Math.max(...nombres.map((n) => (state.clientes[n] || []).length), 1))
    : 1;

  const textoBotonEliminar = () => {
    const vs = state.valorSeleccionado;
    if (!vs || !state.clientes[vs.nombre]) return 'Eliminar Valor';
    const vals = state.clientes[vs.nombre];
    if (vs.indice < 0 || vs.indice >= vals.length) return 'Eliminar Valor';
    return `Eliminar ${formatMoney(vals[vs.indice])} (${vs.nombre})`;
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.titulo}>Tabla de Clientes</Text>
        <TouchableOpacity
          style={styles.btnEliminarValor}
          onPress={onAbrirEliminarValor}
          activeOpacity={0.8}
        >
          <Text style={styles.btnEliminarValorText} numberOfLines={1}>{textoBotonEliminar()}</Text>
        </TouchableOpacity>
      </View>
      <View style={styles.tableWrapper}>
        <ScrollView horizontal style={styles.scrollHorizontal} showsHorizontalScrollIndicator={true}>
          <ScrollView style={styles.scrollVertical} nestedScrollEnabled showsVerticalScrollIndicator={true}>
            <View style={styles.rowHeader}>
              <Text style={[styles.cell, styles.cellNombre, styles.th]}>Nombre</Text>
              {Array.from({ length: maxValores }, (_, i) => (
                <Text key={i} style={[styles.cell, styles.cellValor, styles.th]}>V{i + 1}</Text>
              ))}
              <Text style={[styles.cell, styles.cellTotal, styles.th]}>Total</Text>
            </View>
            {nombres.map((nombre, rowIndex) => {
              const valores = state.clientes[nombre] || [];
              const detalles = state.detalles[nombre] || [];
              const total = valores.reduce((a, b) => a + b, 0);
              const valorSel = state.valorSeleccionado;
              const filaSelected = valorSel && valorSel.nombre === nombre;
              const esPar = rowIndex % 2 === 0;
              return (
                <View
                  key={nombre}
                  style={[
                    styles.row,
                    esPar ? styles.rowEven : styles.rowOdd,
                    filaSelected && styles.rowSelected,
                  ]}
                >
                  <Text style={[styles.cell, styles.cellNombre, styles.cellNombreText]} numberOfLines={1}>{nombre}</Text>
                  {Array.from({ length: maxValores }, (_, i) => {
                    const val = valores[i];
                    const esDetalle = detalles[i];
                    const celdaSelected = valorSel && valorSel.nombre === nombre && valorSel.indice === i;
                    return (
                      <TouchableOpacity
                        key={i}
                        style={[styles.cell, styles.cellValor, celdaSelected && styles.cellSelected]}
                        onPress={() => val != null && dispatch({ type: 'SELECCIONAR_VALOR_TABLA', payload: { nombre, indice: i } })}
                        activeOpacity={0.7}
                      >
                        <Text style={[styles.cellText, esDetalle && styles.cellTextDetalle]} numberOfLines={1}>
                          {val != null ? (esDetalle ? `(${formatMoney(val)})` : formatMoney(val)) : ''}
                        </Text>
                      </TouchableOpacity>
                    );
                  })}
                  <View style={[styles.cell, styles.cellTotal, styles.cellTotalWrap]}>
                    <Text style={styles.cellTotalText} numberOfLines={1}>{formatMoney(total)}</Text>
                  </View>
                </View>
              );
            })}
          </ScrollView>
        </ScrollView>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.bg,
    padding: 16,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 14,
    gap: 10,
  },
  titulo: {
    flex: 1,
    fontSize: 20,
    fontWeight: '700',
    color: colors.text,
    letterSpacing: 0.3,
  },
  btnEliminarValor: {
    backgroundColor: colors.warning,
    paddingVertical: 10,
    paddingHorizontal: 14,
    borderRadius: 10,
    maxWidth: '55%',
  },
  btnEliminarValorText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 13,
  },
  tableWrapper: {
    flex: 1,
    backgroundColor: colors.card,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(42,107,160,0.35)',
    overflow: 'hidden',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.2,
    shadowRadius: 3,
  },
  scrollHorizontal: {
    flex: 1,
  },
  scrollVertical: {
    flex: 1,
  },
  rowHeader: {
    flexDirection: 'row',
    backgroundColor: colors.primary,
    paddingVertical: 12,
    borderBottomWidth: 2,
    borderBottomColor: 'rgba(255,255,255,0.2)',
  },
  row: {
    flexDirection: 'row',
    paddingVertical: 2,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.06)',
  },
  rowEven: {
    backgroundColor: 'rgba(43,43,43,0.6)',
  },
  rowOdd: {
    backgroundColor: 'rgba(33,33,33,0.8)',
  },
  rowSelected: {
    backgroundColor: 'rgba(76,175,80,0.22)',
  },
  cell: {
    minWidth: 76,
    paddingVertical: 12,
    paddingHorizontal: 10,
    justifyContent: 'center',
  },
  cellNombre: {
    minWidth: 110,
    maxWidth: 140,
  },
  cellNombreText: {
    color: colors.text,
    fontSize: 14,
    fontWeight: '600',
  },
  cellValor: {
    alignItems: 'flex-end',
  },
  cellTotal: {
    minWidth: 92,
  },
  cellTotalWrap: {
    backgroundColor: 'rgba(33,150,243,0.18)',
  },
  cellTotalText: {
    color: colors.text,
    fontSize: 14,
    fontWeight: '700',
  },
  cellSelected: {
    backgroundColor: 'rgba(76,175,80,0.5)',
  },
  cellText: {
    color: colors.text,
    fontSize: 13,
    textAlign: 'right',
  },
  cellTextDetalle: {
    color: colors.textMuted,
    fontStyle: 'italic',
  },
  th: {
    backgroundColor: colors.primary,
    color: '#fff',
    fontWeight: '700',
    fontSize: 13,
  },
});
