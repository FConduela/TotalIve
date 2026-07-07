import React, { useState, useCallback } from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { formatMoney } from '../utils/formatMoney';
import { colors } from '../theme';

export function GestionEnviosScreen({ onMarcarComoEnviado }) {
  const { state } = useApp();
  const envios = state.enviosPendientes || {};
  const clientesConEnvios = Object.keys(envios).filter((nombre) => envios[nombre]?.length > 0);
  const [seleccionados, setSeleccionados] = useState({});

  const totalBolsas = clientesConEnvios.reduce((acc, nombre) => acc + (envios[nombre]?.length || 0), 0);
  const totalProductos = clientesConEnvios.reduce((acc, nombre) => {
    const bolsas = envios[nombre] || [];
    return acc + bolsas.reduce((s, b) => s + (b.cantidadItems || 0), 0);
  }, 0);

  const toggleBolsa = useCallback((nombre, idx, totalBolsas) => {
    setSeleccionados((prev) => {
      const actual = prev[nombre] ?? Array.from({ length: totalBolsas }, (_, i) => i);
      const set = new Set(actual);
      if (set.has(idx)) set.delete(idx);
      else set.add(idx);
      return { ...prev, [nombre]: [...set].sort((a, b) => a - b) };
    });
  }, []);

  const marcarTodasBolsas = useCallback((nombre, totalBolsas) => {
    setSeleccionados((prev) => ({ ...prev, [nombre]: Array.from({ length: totalBolsas }, (_, i) => i) }));
  }, []);

  if (clientesConEnvios.length === 0) {
    return (
      <View style={styles.container}>
        <View style={styles.summaryRow}>
          <View style={styles.cardResumen}>
            <Text style={styles.cardResumenValor}>0</Text>
            <Text style={styles.cardResumenLabel}>Total Bolsas Pendientes</Text>
          </View>
          <View style={styles.cardResumen}>
            <Text style={styles.cardResumenValor}>0</Text>
            <Text style={styles.cardResumenLabel}>Total Productos</Text>
          </View>
        </View>
        <View style={styles.empty}>
          <Ionicons name="cube-outline" size={64} color={colors.textMuted} />
          <Text style={styles.emptyText}>Sin envíos pendientes</Text>
          <Text style={styles.emptyHint}>Usa "Cerrar Jornada" en Inicio para acumular bolsas.</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.summaryRow}>
        <View style={styles.cardResumen}>
          <Text style={styles.cardResumenValor}>{totalBolsas}</Text>
          <Text style={styles.cardResumenLabel}>Total Bolsas Pendientes</Text>
        </View>
        <View style={styles.cardResumen}>
          <Text style={styles.cardResumenValor}>{totalProductos}</Text>
          <Text style={styles.cardResumenLabel}>Total Productos</Text>
        </View>
      </View>

      <Text style={styles.tituloLista}>Lista de pendientes</Text>
      <ScrollView style={styles.lista} contentContainerStyle={styles.listaContent}>
        {clientesConEnvios.map((nombre) => {
          const bolsas = envios[nombre] || [];
          const totalBolsasCliente = bolsas.length;
          const seleccion = seleccionados[nombre];
          const indicesSeleccionados = seleccion ?? bolsas.map((_, i) => i);
          const ningunoSeleccionado = indicesSeleccionados.length === 0;
          const todasSeleccionadas = indicesSeleccionados.length === totalBolsasCliente;
          const enviarIndices = todasSeleccionadas || (seleccion == null) ? undefined : indicesSeleccionados;

          return (
            <View key={nombre} style={styles.card}>
              <View style={styles.cardHeader}>
                <Text style={styles.clienteNombre} numberOfLines={1}>{nombre}</Text>
                <Text style={styles.bolsasBadge}>{totalBolsasCliente} Bolsa{totalBolsasCliente !== 1 ? 's' : ''}</Text>
              </View>
              <TouchableOpacity style={styles.linkTodas} onPress={() => marcarTodasBolsas(nombre, totalBolsasCliente)}>
                <Text style={styles.linkTodasText}>Seleccionar todas</Text>
              </TouchableOpacity>
              <View style={styles.detalleBolsas}>
                {bolsas.map((bolsa, i) => {
                  const checked = seleccion == null ? true : indicesSeleccionados.includes(i);
                  return (
                    <TouchableOpacity
                      key={i}
                      style={[styles.bolsaRow, checked && styles.bolsaRowSelected]}
                      onPress={() => toggleBolsa(nombre, i, totalBolsasCliente)}
                      activeOpacity={0.8}
                    >
                      <View style={styles.bolsaRowLeft}>
                        <View style={[styles.checkbox, checked && styles.checkboxChecked]}>
                          {checked && <Ionicons name="checkmark" size={14} color="#fff" />}
                        </View>
                        <Text style={styles.bolsaFecha}>{bolsa.fecha}</Text>
                      </View>
                      <Text style={styles.bolsaMonto}>{formatMoney(bolsa.montoTotal)}</Text>
                    </TouchableOpacity>
                  );
                })}
              </View>
              <TouchableOpacity
                style={[styles.btnMarcarEnviado, ningunoSeleccionado && styles.btnMarcarEnviadoDisabled]}
                onPress={() => !ningunoSeleccionado && onMarcarComoEnviado(nombre, enviarIndices)}
                activeOpacity={0.8}
                disabled={ningunoSeleccionado}
              >
                <Ionicons name="checkmark-done" size={20} color="#fff" />
                <Text style={styles.btnMarcarEnviadoText}>
                  {todasSeleccionadas || seleccion == null
                    ? 'Marcar como Enviado'
                    : `Marcar ${indicesSeleccionados.length} como enviada${indicesSeleccionados.length !== 1 ? 's' : ''}`}
                </Text>
              </TouchableOpacity>
            </View>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.bg,
    padding: 16,
  },
  summaryRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 20,
  },
  cardResumen: {
    flex: 1,
    backgroundColor: colors.card,
    borderRadius: 10,
    padding: 16,
    borderWidth: 1,
    borderColor: 'rgba(42,107,160,0.3)',
    alignItems: 'center',
  },
  cardResumenValor: {
    fontSize: 28,
    fontWeight: '800',
    color: colors.primary,
  },
  cardResumenLabel: {
    fontSize: 12,
    color: colors.textMuted,
    marginTop: 4,
    textAlign: 'center',
  },
  tituloLista: {
    fontSize: 16,
    fontWeight: '700',
    color: colors.textMuted,
    marginBottom: 12,
  },
  lista: {
    flex: 1,
  },
  listaContent: {
    paddingBottom: 24,
  },
  empty: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '600',
    color: colors.textMuted,
    marginTop: 16,
  },
  emptyHint: {
    fontSize: 14,
    color: colors.textMuted,
    marginTop: 8,
    textAlign: 'center',
  },
  card: {
    backgroundColor: colors.card,
    borderRadius: 10,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: 'rgba(42,107,160,0.3)',
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  clienteNombre: {
    flex: 1,
    fontSize: 17,
    fontWeight: '700',
    color: colors.text,
  },
  bolsasBadge: {
    fontSize: 14,
    fontWeight: '700',
    color: colors.warning,
  },
  detalleBolsas: {
    marginBottom: 12,
  },
  linkTodas: {
    marginBottom: 8,
  },
  linkTodasText: {
    fontSize: 13,
    color: colors.primary,
    fontWeight: '600',
  },
  bolsaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 10,
    backgroundColor: colors.input,
    borderRadius: 6,
    marginTop: 6,
  },
  bolsaRowSelected: {
    borderWidth: 1,
    borderColor: 'rgba(76,175,80,0.5)',
  },
  bolsaRowLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  checkbox: {
    width: 22,
    height: 22,
    borderRadius: 4,
    borderWidth: 2,
    borderColor: colors.textMuted,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxChecked: {
    backgroundColor: colors.success,
    borderColor: colors.success,
  },
  bolsaFecha: {
    fontSize: 14,
    color: colors.text,
    fontWeight: '600',
  },
  bolsaMonto: {
    fontSize: 14,
    color: colors.success,
    fontWeight: '700',
  },
  btnMarcarEnviado: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    backgroundColor: colors.success,
    paddingVertical: 12,
    borderRadius: 8,
  },
  btnMarcarEnviadoText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 15,
  },
  btnMarcarEnviadoDisabled: {
    opacity: 0.5,
  },
});
