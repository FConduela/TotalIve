import React, { useState, useCallback } from 'react';
import { StatusBar } from 'expo-status-bar';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';

import { AppProvider, useApp } from './src/context/AppContext';
import { InicioScreen } from './src/screens/InicioScreen';
import { TablaScreen } from './src/screens/TablaScreen';
import { GestionEnviosScreen } from './src/screens/GestionEnviosScreen';
import { ModalNuevoCliente } from './src/components/ModalNuevoCliente';
import { ModalValores } from './src/components/ModalValores';
import { ModalConfirmar } from './src/components/ModalConfirmar';
import { Toast } from './src/components/Toast';
import { syncCerrarJornada } from './src/services/syncService';
import { colors } from './src/theme';

const Tab = createBottomTabNavigator();

function MainTabs() {
  const { state, dispatch } = useApp();
  const [modalNuevoCliente, setModalNuevoCliente] = useState(false);
  const [modalValores, setModalValores] = useState(false);
  const [modalEliminarCliente, setModalEliminarCliente] = useState(false);
  const [modalEliminarValor, setModalEliminarValor] = useState(false);
  const [modalCerrarJornada, setModalCerrarJornada] = useState(false);
  const [clienteDespacharConfirmar, setClienteDespacharConfirmar] = useState(null);
  const [toast, setToast] = useState({ visible: false, text: '', tipo: 'agregado' });

  const showToast = useCallback((text, tipo) => {
    setToast({ visible: true, text, tipo });
  }, []);

  const hideToast = useCallback(() => {
    setToast((t) => ({ ...t, visible: false }));
  }, []);

  const abrirValores = useCallback((nombre) => {
    dispatch({ type: 'SELECCIONAR_CLIENTE', payload: nombre });
    setModalValores(true);
  }, [dispatch]);

  const agregarCliente = useCallback((nombre, valor) => {
    dispatch({ type: 'AGREGAR_CLIENTE', payload: { nombre, valor } });
  }, [dispatch]);

  const agregarValor = useCallback((valor, esDetalle) => {
    dispatch({ type: 'AGREGAR_VALOR', payload: { valor, esDetalle } });
  }, [dispatch]);

  const confirmarEliminarCliente = useCallback(() => {
    dispatch({ type: 'ELIMINAR_CLIENTE' });
    setModalEliminarCliente(false);
    showToast('✓ Cliente eliminado', 'eliminado');
  }, [dispatch, showToast]);

  const confirmarEliminarValor = useCallback(() => {
    dispatch({ type: 'ELIMINAR_VALOR_SELECCIONADO' });
    setModalEliminarValor(false);
    showToast('✓ Valor eliminado', 'eliminado');
  }, [dispatch, showToast]);

  const confirmarCerrarJornada = useCallback(() => {
    const clientesConVentas = Object.keys(state.clientes).filter((n) => (state.clientes[n]?.length || 0) > 0);
    const cantidadBolsas = clientesConVentas.length;
    syncCerrarJornada(state.clientes).catch(() => {});
    dispatch({ type: 'CERRAR_JORNADA' });
    setModalCerrarJornada(false);
    showToast(cantidadBolsas > 0 ? `Se generaron ${cantidadBolsas} bolsa${cantidadBolsas !== 1 ? 's' : ''}` : 'Jornada cerrada', 'agregado');
  }, [dispatch, showToast, state.clientes]);

  const confirmarMarcarEnviado = useCallback(() => {
    if (clienteDespacharConfirmar) {
      const { nombre, indices } = clienteDespacharConfirmar;
      dispatch({ type: 'DESPACHAR', payload: { nombre, indices } });
      setClienteDespacharConfirmar(null);
      showToast('Envío marcado como realizado', 'agregado');
    }
  }, [dispatch, showToast, clienteDespacharConfirmar]);

  return (
    <>
      <Tab.Navigator
        screenOptions={{
          headerStyle: { backgroundColor: colors.card },
          headerTintColor: colors.text,
          tabBarStyle: { backgroundColor: colors.card },
          tabBarActiveTintColor: colors.selected,
          tabBarInactiveTintColor: colors.textMuted,
        }}
      >
        <Tab.Screen
          name="Inicio"
          options={{
            title: 'Inicio',
            tabBarIcon: ({ color, size }) => <Ionicons name="home" size={size} color={color} />,
          }}
        >
          {() => (
            <InicioScreen
              onAbrirNuevoCliente={() => setModalNuevoCliente(true)}
              onAbrirValores={abrirValores}
              onCerrarJornada={() => setModalCerrarJornada(true)}
            />
          )}
        </Tab.Screen>
        <Tab.Screen
          name="Tabla"
          options={{
            title: 'Tabla',
            tabBarIcon: ({ color, size }) => <Ionicons name="grid" size={size} color={color} />,
          }}
        >
          {() => (
            <TablaScreen
              onAbrirEliminarValor={() => state.valorSeleccionado && setModalEliminarValor(true)}
            />
          )}
        </Tab.Screen>
        <Tab.Screen
          name="GestionEnvios"
          options={{
            title: 'Gestión de Envíos',
            tabBarLabel: 'Envíos',
            tabBarIcon: ({ color, size }) => <Ionicons name="cube-outline" size={size} color={color} />,
          }}
        >
          {() => (
            <GestionEnviosScreen
              onMarcarComoEnviado={(nombre, indices) => setClienteDespacharConfirmar({ nombre, indices })}
            />
          )}
        </Tab.Screen>
      </Tab.Navigator>

      <ModalNuevoCliente
        visible={modalNuevoCliente}
        onCerrar={() => setModalNuevoCliente(false)}
        onAgregar={agregarCliente}
      />

      <ModalValores
        visible={modalValores}
        nombreCliente={state.clienteSeleccionado || ''}
        onCerrar={() => setModalValores(false)}
        onAgregarValor={agregarValor}
        onToast={showToast}
        onEliminarCliente={() => {
          setModalValores(false);
          setModalEliminarCliente(true);
        }}
      />

      <ModalConfirmar
        visible={modalEliminarCliente}
        titulo={state.clienteSeleccionado ? `¿Desea eliminar a ${state.clienteSeleccionado}?` : ''}
        onCancelar={() => setModalEliminarCliente(false)}
        onConfirmar={confirmarEliminarCliente}
      />

      <ModalConfirmar
        visible={modalEliminarValor}
        titulo="¿Seguro que desea eliminar el valor?"
        onCancelar={() => setModalEliminarValor(false)}
        onConfirmar={confirmarEliminarValor}
      />

      <ModalConfirmar
        visible={modalCerrarJornada}
        titulo="Se generarán bolsas con las ventas actuales y se limpiarán los contadores del día. ¿Continuar?"
        onCancelar={() => setModalCerrarJornada(false)}
        onConfirmar={confirmarCerrarJornada}
      />

      <ModalConfirmar
        visible={!!clienteDespacharConfirmar}
        titulo={clienteDespacharConfirmar
          ? (clienteDespacharConfirmar.indices == null || clienteDespacharConfirmar.indices.length === 0
            ? `¿Marcar todas las bolsas de ${clienteDespacharConfirmar.nombre} como enviadas?`
            : `¿Marcar ${clienteDespacharConfirmar.indices.length} bolsa(s) de ${clienteDespacharConfirmar.nombre} como enviadas?`)
          : ''}
        onCancelar={() => setClienteDespacharConfirmar(null)}
        onConfirmar={confirmarMarcarEnviado}
      />

      <Toast
        visible={toast.visible}
        text={toast.text}
        tipo={toast.tipo}
        onHide={hideToast}
      />
    </>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AppProvider>
        <NavigationContainer>
          <StatusBar style="light" />
          <MainTabs />
        </NavigationContainer>
      </AppProvider>
    </SafeAreaProvider>
  );
}
