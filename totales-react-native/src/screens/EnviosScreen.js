import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { formatMoney } from '../utils/formatMoney';
import { colors } from '../theme';

export function EnviosScreen() {
  const { state, dispatch } = useApp();
  const envios = state.enviosPendientes || {};
  const clientesConEnvios = Object.keys(envios).filter((nombre) => envios[nombre]?.length > 0);

  const despachar = (nombre) => {
    dispatch({ type: 'DESPACHAR', payload: { nombre } });
  };

  if (clientesConEnvios.length === 0) {
    return (
      <View style={styles.container}>
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
      <Text style={styles.titulo}>Envíos pendientes</Text>
      <ScrollView style={styles.lista} contentContainerStyle={styles.listaContent}>
        {clientesConEnvios.map((nombre) => {
          const bolsas = envios[nombre] || [];
          const totalBolsas = bolsas.length;
          const montoTotal = bolsas.reduce((a, b) => a + b.montoTotal, 0);
          const itemsTotal = bolsas.reduce((a, b) => a + b.cantidadItems, 0);
          return (
            <View key={nombre} style={styles.card}>
              <View style={styles.cardHeader}>
                <Text style={styles.clienteNombre} numberOfLines={1}>{nombre}</Text>
                <TouchableOpacity
                  style={styles.btnDespachar}
                  onPress={() => despachar(nombre)}
                  activeOpacity={0.8}
                >
                  <Ionicons name="checkmark-done" size={20} color="#fff" />
                  <Text style={styles.btnDespacharText}>Despachar</Text>
                </TouchableOpacity>
              </View>
              <View style={styles.resumen}>
                <Text style={styles.resumenText}>{totalBolsas} bolsa{totalBolsas !== 1 ? 's' : ''} · {itemsTotal} ítems · {formatMoney(montoTotal)}</Text>
              </View>
              {bolsas.map((bolsa, i) => (
                <View key={i} style={styles.bolsaRow}>
                  <Text style={styles.bolsaFecha}>{bolsa.fecha}</Text>
                  <Text style={styles.bolsaDatos}>{bolsa.cantidadItems} ítems · {formatMoney(bolsa.montoTotal)}</Text>
                </View>
              ))}
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
  titulo: {
    fontSize: 20,
    fontWeight: '700',
    color: colors.text,
    marginBottom: 16,
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
    marginBottom: 10,
  },
  clienteNombre: {
    flex: 1,
    fontSize: 17,
    fontWeight: '700',
    color: colors.text,
  },
  btnDespachar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    backgroundColor: colors.success,
    paddingVertical: 8,
    paddingHorizontal: 14,
    borderRadius: 8,
  },
  btnDespacharText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 14,
  },
  resumen: {
    marginBottom: 10,
    paddingBottom: 10,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255,255,255,0.08)',
  },
  resumenText: {
    fontSize: 14,
    color: colors.textMuted,
  },
  bolsaRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 6,
    paddingHorizontal: 8,
    backgroundColor: colors.input,
    borderRadius: 6,
    marginTop: 6,
  },
  bolsaFecha: {
    fontSize: 14,
    color: colors.text,
    fontWeight: '600',
  },
  bolsaDatos: {
    fontSize: 14,
    color: colors.success,
    fontWeight: '600',
  },
});
