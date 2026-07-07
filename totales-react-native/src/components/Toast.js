import React, { useEffect } from 'react';
import { View, Text, StyleSheet, Modal } from 'react-native';
import { colors } from '../theme';

const DURACION_MS = 1000;

export function Toast({ visible, text, tipo, onHide }) {
  useEffect(() => {
    if (!visible) return;
    const t = setTimeout(() => onHide(), DURACION_MS);
    return () => clearTimeout(t);
  }, [visible, onHide]);

  if (!visible) return null;

  return (
    <Modal transparent visible={visible} animationType="fade">
      <View style={styles.overlay}>
        <View style={[styles.box, tipo === 'eliminado' && { backgroundColor: colors.warning }]}>
          <Text style={styles.text}>{text}</Text>
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
    backgroundColor: 'rgba(0,0,0,0.4)',
  },
  box: {
    backgroundColor: colors.success,
    paddingVertical: 14,
    paddingHorizontal: 24,
    borderRadius: 8,
    maxWidth: '90%',
  },
  text: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 16,
  },
});
