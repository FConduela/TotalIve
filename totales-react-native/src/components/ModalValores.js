import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Modal,
  StyleSheet,
  ScrollView,
  Switch,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, VALORES_BOTONES } from '../theme';
import { formatMoney } from '../utils/formatMoney';

export function ModalValores({ visible, nombreCliente, onCerrar, onAgregarValor, onToast, onEliminarCliente }) {
  const [detalle, setDetalle] = useState(false);
  const [otroValor, setOtroValor] = useState('');

  const agregar = (valor) => {
    onAgregarValor(valor, detalle);
    setDetalle(false);
    if (onToast) onToast('Valor agregado: ' + formatMoney(valor), 'agregado');
  };

  const agregarOtro = () => {
    const v = parseInt((otroValor || '').trim(), 10);
    if (isNaN(v)) return;
    agregar(v);
    setOtroValor('');
  };

  if (!visible) return null;

  return (
    <Modal transparent visible={visible} animationType="slide">
      <View style={styles.overlay}>
        <View style={styles.caja}>
          <View style={styles.header}>
            <TouchableOpacity
              style={styles.btnEliminarCliente}
              onPress={onEliminarCliente}
              activeOpacity={0.8}
            >
              <Ionicons name="trash-outline" size={22} color="#fff" />
            </TouchableOpacity>
            <Text style={styles.titulo} numberOfLines={1}>{nombreCliente}</Text>
            <TouchableOpacity style={styles.btnCerrar} onPress={onCerrar}>
              <Text style={styles.btnCerrarIcono}>✕</Text>
            </TouchableOpacity>
          </View>
          <View style={styles.detalleRow}>
            <Text style={styles.detalleLabel}>Detalle:</Text>
            <Switch value={detalle} onValueChange={setDetalle} trackColor={{ false: '#555', true: colors.primary }} thumbColor="#fff" />
          </View>
          <ScrollView style={styles.gridScroll} contentContainerStyle={styles.gridContainer}>
            {VALORES_BOTONES.map((v) => (
              <TouchableOpacity
                key={v}
                style={styles.btnValor}
                onPress={() => agregar(v)}
                activeOpacity={0.8}
              >
                <Text style={styles.btnValorText}>{v}</Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
          <View style={styles.otroRow}>
            <TextInput
              style={styles.inputOtro}
              value={otroValor}
              onChangeText={setOtroValor}
              placeholder="Otro valor"
              placeholderTextColor={colors.textMuted}
              keyboardType="numeric"
            />
            <TouchableOpacity style={styles.btnOtro} onPress={agregarOtro}>
              <Text style={styles.btnOtroText}>+</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'rgba(0,0,0,0.6)',
  },
  caja: {
    backgroundColor: colors.card,
    padding: 20,
    borderRadius: 10,
    width: '90%',
    maxWidth: 420,
    maxHeight: '85%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(42,107,160,0.3)',
  },
  titulo: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.text,
    flex: 1,
    marginHorizontal: 10,
  },
  btnEliminarCliente: {
    width: 40,
    height: 40,
    borderRadius: 8,
    backgroundColor: colors.danger,
    justifyContent: 'center',
    alignItems: 'center',
  },
  btnCerrar: {
    width: 40,
    height: 40,
    borderRadius: 8,
    backgroundColor: colors.danger,
    justifyContent: 'center',
    alignItems: 'center',
  },
  btnCerrarIcono: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '700',
  },
  detalleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    gap: 8,
  },
  detalleLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.text,
  },
  gridScroll: {
    maxHeight: 320,
  },
  gridContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    justifyContent: 'space-between',
  },
  btnValor: {
    width: '48%',
    minHeight: 44,
    backgroundColor: colors.primary,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  btnValorText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
  },
  otroRow: {
    flexDirection: 'row',
    gap: 8,
    marginTop: 12,
    alignItems: 'center',
  },
  inputOtro: {
    flex: 1,
    backgroundColor: colors.input,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: colors.text,
  },
  btnOtro: {
    width: 50,
    height: 48,
    backgroundColor: colors.success,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  btnOtroText: {
    color: '#fff',
    fontSize: 20,
    fontWeight: '700',
  },
});
