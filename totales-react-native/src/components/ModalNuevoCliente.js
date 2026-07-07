import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Modal,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { colors } from '../theme';

export function ModalNuevoCliente({ visible, onCerrar, onAgregar }) {
  const [nombre, setNombre] = useState('');
  const [valorStr, setValorStr] = useState('');

  const agregar = () => {
    const n = (nombre || '').trim();
    const v = parseInt((valorStr || '').trim(), 10);
    if (!n || isNaN(v)) return;
    onAgregar(n, v);
    setNombre('');
    setValorStr('');
    onCerrar();
  };

  return (
    <Modal transparent visible={visible} animationType="slide">
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
        style={styles.overlay}
      >
        <View style={styles.caja}>
          <View style={styles.header}>
            <Text style={styles.titulo}>Nuevo Cliente</Text>
            <TouchableOpacity style={styles.btnCerrar} onPress={onCerrar}>
              <Text style={styles.btnCerrarIcono}>✕</Text>
            </TouchableOpacity>
          </View>
          <Text style={styles.label}>Nombre del Cliente</Text>
          <TextInput
            style={styles.input}
            value={nombre}
            onChangeText={setNombre}
            placeholder="Ingresa el nombre..."
            placeholderTextColor={colors.textMuted}
            autoCapitalize="none"
          />
          <Text style={styles.label}>Valor Inicial</Text>
          <TextInput
            style={styles.input}
            value={valorStr}
            onChangeText={setValorStr}
            placeholder="Valor..."
            placeholderTextColor={colors.textMuted}
            keyboardType="numeric"
          />
          <TouchableOpacity style={styles.btnAgregar} onPress={agregar}>
            <Text style={styles.btnAgregarText}>+ Agregar Cliente</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
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
    maxWidth: 360,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(42,107,160,0.3)',
  },
  titulo: {
    fontSize: 18,
    fontWeight: '700',
    color: colors.text,
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
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textMuted,
    marginBottom: 6,
  },
  input: {
    backgroundColor: colors.input,
    borderWidth: 1,
    borderColor: colors.border,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: colors.text,
    marginBottom: 14,
  },
  btnAgregar: {
    backgroundColor: colors.success,
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 8,
  },
  btnAgregarText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 16,
  },
});
