import React, { createContext, useContext, useReducer, useEffect, useRef } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

const STORAGE_KEY = '@totales_app_data';

/** Cada bolsa en envíos pendientes: { fecha (YYYY-MM-DD), cantidadItems, montoTotal } */
const initialState = {
  clientes: {},
  detalles: {},
  clienteOrden: [],
  clienteSeleccionado: null,
  valorSeleccionado: null,
  /** { [nombreCliente]: Array<{ fecha, cantidadItems, montoTotal }> } */
  enviosPendientes: {},
};

function getTotalGeneral(clientes) {
  return Object.values(clientes).reduce(
    (acc, vals) => acc + vals.reduce((a, b) => a + b, 0),
    0
  );
}

function getOrdenClientes(state) {
  const tieneVentasOEnvios = (n) => (state.clientes[n]?.length > 0) || (state.enviosPendientes && state.enviosPendientes[n]?.length > 0);
  const ordenados = state.clienteOrden.filter(tieneVentasOEnvios);
  const keysClientes = Object.keys(state.clientes).filter((n) => (state.clientes[n]?.length > 0));
  const keysEnvios = Object.keys(state.enviosPendientes || {}).filter((n) => (state.enviosPendientes[n]?.length > 0));
  const todasLasClaves = [...new Set([...keysClientes, ...keysEnvios])];
  const restantes = todasLasClaves.filter((n) => state.clienteOrden.indexOf(n) === -1);
  return ordenados.concat(restantes);
}

function appReducer(state, action) {
  switch (action.type) {
    case 'AGREGAR_CLIENTE': {
      const { nombre, valor } = action.payload;
      if (state.clientes[nombre]) return state;
      return {
        ...state,
        clientes: { ...state.clientes, [nombre]: [valor] },
        detalles: { ...state.detalles, [nombre]: [false] },
        clienteOrden: [nombre].concat(state.clienteOrden.filter((n) => n !== nombre)),
      };
    }
    case 'SELECCIONAR_CLIENTE': {
      return {
        ...state,
        clienteSeleccionado: action.payload,
        valorSeleccionado: null,
      };
    }
    case 'AGREGAR_VALOR': {
      const { valor, esDetalle } = action.payload;
      const nombre = state.clienteSeleccionado;
      if (!nombre || !state.clientes[nombre]) return state;
      const valores = [...state.clientes[nombre], valor];
      const det = state.detalles[nombre] || [];
      return {
        ...state,
        clientes: { ...state.clientes, [nombre]: valores },
        detalles: { ...state.detalles, [nombre]: [...det, esDetalle] },
        clienteOrden: [nombre].concat(state.clienteOrden.filter((n) => n !== nombre)),
      };
    }
    case 'ELIMINAR_CLIENTE': {
      const nombre = state.clienteSeleccionado;
      if (!nombre || !state.clientes[nombre]) return state;
      const { [nombre]: _, ...clientes } = state.clientes;
      const { [nombre]: __, ...detalles } = state.detalles;
      const { [nombre]: ___, ...enviosPendientes } = state.enviosPendientes || {};
      return {
        ...state,
        clientes,
        detalles,
        enviosPendientes,
        clienteOrden: state.clienteOrden.filter((n) => n !== nombre),
        clienteSeleccionado: null,
        valorSeleccionado: null,
      };
    }
    case 'ELIMINAR_VALOR_SELECCIONADO': {
      const { nombre, indice } = state.valorSeleccionado || {};
      if (!nombre || !state.clientes[nombre] || indice == null) return state;
      const valores = state.clientes[nombre].filter((_, i) => i !== indice);
      const det = (state.detalles[nombre] || []).filter((_, i) => i !== indice);
      if (valores.length === 0) {
        const { [nombre]: _, ...clientes } = state.clientes;
        const { [nombre]: __, ...detalles } = state.detalles;
        return {
          ...state,
          clientes,
          detalles,
          clienteOrden: state.clienteOrden.filter((n) => n !== nombre),
          clienteSeleccionado: null,
          valorSeleccionado: null,
        };
      }
      return {
        ...state,
        clientes: { ...state.clientes, [nombre]: valores },
        detalles: { ...state.detalles, [nombre]: det },
        valorSeleccionado: null,
        clienteSeleccionado: nombre,
      };
    }
    case 'SELECCIONAR_VALOR_TABLA': {
      return {
        ...state,
        valorSeleccionado: action.payload,
        clienteSeleccionado: action.payload?.nombre ?? state.clienteSeleccionado,
      };
    }
    case 'LIMPIAR_SELECCION_VALOR': {
      return { ...state, valorSeleccionado: null };
    }
    case 'CERRAR_JORNADA': {
      const fecha = new Date().toISOString().slice(0, 10);
      let nextClientes = { ...state.clientes };
      let nextDetalles = { ...state.detalles };
      let nextEnvios = { ...(state.enviosPendientes || {}) };
      Object.keys(state.clientes).forEach((nombre) => {
        const valores = state.clientes[nombre] || [];
        if (valores.length === 0) return;
        const montoTotal = valores.reduce((a, b) => a + b, 0);
        const bolsa = { fecha, cantidadItems: valores.length, montoTotal };
        nextEnvios[nombre] = [...(nextEnvios[nombre] || []), bolsa];
        nextClientes[nombre] = [];
        nextDetalles[nombre] = [];
      });
      return {
        ...state,
        clientes: nextClientes,
        detalles: nextDetalles,
        enviosPendientes: nextEnvios,
        clienteSeleccionado: null,
        valorSeleccionado: null,
      };
    }
    case 'DESPACHAR': {
      const { nombre, indices } = action.payload || {};
      if (!nombre || !state.enviosPendientes?.[nombre]) return state;
      const bolsas = state.enviosPendientes[nombre];
      let nuevasBolsas;
      if (indices == null || indices.length === 0 || indices.length >= bolsas.length) {
        const { [nombre]: _, ...rest } = state.enviosPendientes || {};
        nuevasBolsas = rest;
      } else {
        const indicesSet = new Set(indices);
        nuevasBolsas = bolsas.filter((_, i) => !indicesSet.has(i));
        if (nuevasBolsas.length === 0) {
          const { [nombre]: _, ...rest } = state.enviosPendientes || {};
          return { ...state, enviosPendientes: rest };
        }
        return {
          ...state,
          enviosPendientes: { ...state.enviosPendientes, [nombre]: nuevasBolsas },
        };
      }
      return { ...state, enviosPendientes: nuevasBolsas };
    }
    case 'RESTORE': {
      const { clientes = {}, detalles = {}, clienteOrden = [], enviosPendientes = {} } = action.payload || {};
      return {
        ...state,
        clientes,
        detalles,
        clienteOrden,
        enviosPendientes,
        clienteSeleccionado: null,
        valorSeleccionado: null,
      };
    }
    default:
      return state;
  }
}

const AppContext = createContext(null);

function persistData(clientes, detalles, clienteOrden, enviosPendientes) {
  try {
    AsyncStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({ clientes, detalles, clienteOrden, enviosPendientes: enviosPendientes || {} })
    );
  } catch (e) {
    // ignore storage errors
  }
}

export function AppProvider({ children }) {
  const [state, dispatch] = useReducer(appReducer, initialState);
  const hasHydrated = useRef(false);

  // Cargar datos guardados al abrir la app
  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const raw = await AsyncStorage.getItem(STORAGE_KEY);
        if (cancelled) return;
        if (raw) {
          const data = JSON.parse(raw);
          if (data && (data.clientes != null || data.detalles != null || data.clienteOrden != null || data.enviosPendientes != null)) {
            dispatch({ type: 'RESTORE', payload: data });
          }
        }
      } catch (_) {
        // usar estado inicial si falla la lectura
      }
      if (!cancelled) hasHydrated.current = true;
    })();
    return () => { cancelled = true; };
  }, []);

  // Guardar cuando cambien clientes, detalles, orden o envíos (solo después de haber cargado)
  useEffect(() => {
    if (!hasHydrated.current) return;
    persistData(state.clientes, state.detalles, state.clienteOrden, state.enviosPendientes);
  }, [state.clientes, state.detalles, state.clienteOrden, state.enviosPendientes]);

  const totalGeneral = getTotalGeneral(state.clientes);
  const ordenClientes = getOrdenClientes(state);

  const value = {
    state,
    dispatch,
    totalGeneral,
    ordenClientes,
  };
  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}

export { getOrdenClientes, getTotalGeneral };
