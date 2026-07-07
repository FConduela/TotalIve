import React from 'react';
import { View, Text, TouchableOpacity, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useApp } from '../context/AppContext';
import { formatMoney } from '../utils/formatMoney';
import { colors } from '../theme';

export function InicioScreen({
  onAbrirNuevoCliente,
  onAbrirValores,
  onCerrarJornada,
}) {
  const { state, ordenClientes, totalGeneral } = useApp();

  return (
    <View style={styles.container}>
      <View style={styles.card}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.btnIcon} onPress={onAbrirNuevoCliente}>
            <Ionicons name="person-add" size={24} color="#fff" />
          </TouchableOpacity>
          <Text style={styles.titulo}>Clientes</Text>
          <View style={styles.headerPlaceholder} />
        </View>
        <ScrollView style={styles.lista} contentContainerStyle={styles.listaContent}>
          {ordenClientes.map((nombre) => {
            const valores = state.clientes[nombre] || [];
            const total = valores.reduce((a, b) => a + b, 0);
            const selected = state.clienteSeleccionado === nombre;
            return (
              <TouchableOpacity
                key={nombre}
                style={[styles.clienteItem, selected && styles.clienteItemSelected]}
                onPress={() => onAbrirValores(nombre)}
                activeOpacity={0.8}
              >
                <Text style={styles.clienteNombre} numberOfLines={1}>{nombre}</Text>
                <View style={styles.clienteDatos}>
                  <Text style={styles.clienteTotal}>Total: {formatMoney(total)}</Text>
                  <Text style={styles.clienteCantidad}>Cantidad: {valores.length}</Text>
                </View>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
        <View style={styles.filaTotalReiniciar}>
          <View style={styles.totalGeneral}>
            <Text style={styles.totalGeneralText}>Total General: {formatMoney(totalGeneral)}</Text>
          </View>
          <TouchableOpacity style={styles.btnCerrarJornada} onPress={onCerrarJornada}>
            <Text style={styles.btnCerrarJornadaText}>Cerrar Jornada</Text>
          </TouchableOpacity>
        </View>
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
  card: {
    backgroundColor: colors.card,
    borderRadius: 10,
    padding: 16,
    flex: 1,
    borderWidth: 1,
    borderColor: 'rgba(42,107,160,0.3)',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  btnIcon: {
    width: 44,
    height: 44,
    borderRadius: 8,
    backgroundColor: colors.success,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerPlaceholder: {
    width: 44,
    height: 44,
  },
  titulo: {
    flex: 1,
    fontSize: 18,
    fontWeight: '700',
    color: colors.text,
    textAlign: 'center',
  },
  filaTotalReiniciar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 12,
    gap: 8,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: 'rgba(42,107,160,0.2)',
  },
  totalGeneral: {
    paddingVertical: 12,
    paddingHorizontal: 12,
    backgroundColor: colors.totalBadge,
    borderRadius: 8,
    flex: 1,
    minHeight: 48,
    justifyContent: 'center',
  },
  btnCerrarJornada: {
    paddingVertical: 12,
    paddingHorizontal: 12,
    backgroundColor: colors.primary,
    borderRadius: 8,
    minHeight: 48,
    justifyContent: 'center',
  },
  btnCerrarJornadaText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#fff',
  },
  lista: {
    flex: 1,
  },
  listaContent: {
    paddingBottom: 16,
  },
  clienteItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    paddingHorizontal: 12,
    marginBottom: 8,
    backgroundColor: colors.input,
    borderRadius: 8,
  },
  clienteItemSelected: {
    backgroundColor: 'rgba(76,175,80,0.25)',
  },
  clienteNombre: {
    flex: 1,
    fontSize: 15,
    color: colors.text,
    maxWidth: '40%',
  },
  clienteDatos: {
    marginLeft: 'auto',
    flexDirection: 'row',
    gap: 12,
  },
  clienteTotal: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.success,
  },
  clienteCantidad: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.warning,
  },
  totalGeneralText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
  },
});
