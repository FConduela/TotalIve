import React from 'react';
import { View, Text, TouchableOpacity, Modal, StyleSheet } from 'react-native';
import { colors } from '../theme';

export function ModalConfirmar({ visible, titulo, onCancelar, onConfirmar }) {
  return (
    <Modal transparent visible={visible} animationType="fade">
      <View style={styles.overlay}>
        <View style={styles.caja}>
          <Text style={styles.titulo}>{titulo}</Text>
          <View style={styles.botones}>
            <TouchableOpacity style={[styles.btn, styles.btnRechazar]} onPress={onCancelar} activeOpacity={0.8}>
              <Text style={styles.icono}>✕</Text>
            </TouchableOpacity>
            <TouchableOpacity style={[styles.btn, styles.btnAceptar]} onPress={onConfirmar} activeOpacity={0.8}>
              <Text style={styles.icono}>✓</Text>
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
    padding: 24,
    borderRadius: 10,
    minWidth: 280,
    maxWidth: '90%',
  },
  titulo: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.text,
    marginBottom: 20,
    textAlign: 'center',
  },
  botones: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 16,
  },
  btn: {
    width: 48,
    height: 48,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  btnRechazar: {
    backgroundColor: colors.danger,
  },
  btnAceptar: {
    backgroundColor: colors.success,
  },
  icono: {
    color: '#fff',
    fontSize: 22,
    fontWeight: '700',
  },
});
