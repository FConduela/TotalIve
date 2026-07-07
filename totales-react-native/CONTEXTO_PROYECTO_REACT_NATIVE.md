# Contexto completo del proyecto: Totales (React Native / Expo)

Documento para traspaso a otra IA: descripción del proyecto, stack, estado, pantallas, componentes y flujos.

---

## 1. Descripción general

**Nombre:** Totales - Gestión de Clientes  
**Tipo:** App móvil (React Native con Expo SDK 54).  
**Objetivo:** Gestionar clientes; cada cliente tiene una lista de valores numéricos. Se muestran totales por cliente y un total general. Es un clon en React Native de una versión web existente.

**Entorno:** Funciona al 100 % en **Expo Go** (no requiere development build). Orientación: `default` (la app gira con el dispositivo). Persistencia local con AsyncStorage para no perder datos al cerrar.

---

## 2. Stack técnico

- **Expo** ~54, **React** 19.1, **React Native** 0.81.5  
- **Navegación:** `@react-navigation/native` + `@react-navigation/bottom-tabs`  
- **Persistencia:** `@react-native-async-storage/async-storage`  
- **Iconos:** `@expo/vector-icons` (Ionicons)  
- **Otros:** `expo-status-bar`, `react-native-safe-area-context`, `react-native-screens`  
- **Babel:** `babel-preset-expo`  
- **Config:** `app.json` (Expo), `babel.config.js`  
- **Punto de entrada:** `App.js` (envuelto por Expo en `main`)

---

## 3. Estructura de archivos

```
totales-react-native/
├── App.js                    # Raíz: SafeAreaProvider, AppProvider, NavigationContainer, tabs, modales, Toast
├── app.json                  # Expo: name, slug, orientation: "default", theme dark, android package
├── babel.config.js           # presets: ['babel-preset-expo']
├── package.json
├── src/
│   ├── context/
│   │   └── AppContext.js     # Estado global, reducer, persistencia AsyncStorage, useApp()
│   ├── screens/
│   │   ├── InicioScreen.js   # Lista de clientes, total general, botón Reiniciar
│   │   └── TablaScreen.js    # Tabla de clientes/valores, eliminar valor
│   ├── components/
│   │   ├── ModalNuevoCliente.js
│   │   ├── ModalValores.js
│   │   ├── ModalConfirmar.js
│   │   └── Toast.js
│   ├── theme.js              # colors + VALORES_BOTONES
│   └── utils/
│       └── formatMoney.js    # Formato moneda: '$' + toLocaleString('es')
```

---

## 4. Estado global (AppContext)

**Clave de almacenamiento:** `@totales_app_data`

**Estado:**

- `clientes`: objeto `{ [nombreCliente]: number[] }` — lista de valores por cliente.
- `detalles`: objeto `{ [nombreCliente]: boolean[] }` — por cada valor, si es “detalle” (se muestra entre paréntesis en tabla).
- `clienteOrden`: array de nombres — orden de aparición (el más reciente primero).
- `clienteSeleccionado`: string | null — cliente actualmente seleccionado (para modal Valores y eliminar).
- `valorSeleccionado`: `{ nombre, indice } | null` — valor seleccionado en la tabla (para eliminar valor).

**Acciones del reducer:**

- `AGREGAR_CLIENTE`: payload `{ nombre, valor }`. Añade cliente con un valor inicial; no hace nada si el nombre ya existe.
- `SELECCIONAR_CLIENTE`: payload `nombre`. Pone `clienteSeleccionado` y limpia `valorSeleccionado`.
- `AGREGAR_VALOR`: payload `{ valor, esDetalle }`. Añade valor al `clienteSeleccionado` y actualiza orden.
- `ELIMINAR_CLIENTE`: elimina `clienteSeleccionado` de clientes/detalles/orden y limpia selecciones.
- `ELIMINAR_VALOR_SELECCIONADO`: elimina el valor indicado en `valorSeleccionado`; si el cliente se queda sin valores, se elimina el cliente.
- `SELECCIONAR_VALOR_TABLA`: payload `{ nombre, indice }`. Actualiza `valorSeleccionado` y opcionalmente `clienteSeleccionado`.
- `LIMPIAR_SELECCION_VALOR`: pone `valorSeleccionado` en null.
- `RESTORE`: payload `{ clientes, detalles, clienteOrden }`. Restaura estado persistido; limpia selecciones. Se usa al cargar desde AsyncStorage y al “Reiniciar” (vacío).

**Persistencia:**

- Al montar: se lee AsyncStorage y, si hay datos, se hace `dispatch(RESTORE, data)`.
- Tras hidratar: cada cambio en `clientes`, `detalles` o `clienteOrden` guarda en AsyncStorage (mismo objeto serializado).
- Solo se persisten `clientes`, `detalles`, `clienteOrden`. No se persisten selecciones.

**API del contexto:**

- `useApp()` devuelve: `{ state, dispatch, totalGeneral, ordenClientes }`.
- `totalGeneral`: suma de todos los valores de todos los clientes.
- `ordenClientes`: array de nombres ordenados (primero los de `clienteOrden` que sigan existiendo, luego el resto).

---

## 5. Navegación y App.js

- **Contenedores:** `SafeAreaProvider` → `AppProvider` → `NavigationContainer` → `Tab.Navigator` (bottom tabs).
- **Tabs:**  
  - **Inicio:** título "Inicio", icono `home` (Ionicons). Renderiza `InicioScreen` con callbacks para abrir modales.  
  - **Tabla:** título "Tabla", icono `grid`. Renderiza `TablaScreen` con callback para abrir modal eliminar valor.
- **Estado local en MainTabs (App.js):**  
  - `modalNuevoCliente`, `modalValores`, `modalEliminarCliente`, `modalEliminarValor`, `modalReiniciar` (boolean).  
  - `toast`: `{ visible, text, tipo }` con `tipo` 'agregado' | 'eliminado'.
- **Callbacks:**  
  - `showToast(text, tipo)`, `hideToast()`  
  - `abrirValores(nombre)` → dispatch SELECCIONAR_CLIENTE + abrir modal Valores  
  - `agregarCliente(nombre, valor)` → dispatch AGREGAR_CLIENTE  
  - `agregarValor(valor, esDetalle)` → dispatch AGREGAR_VALOR  
  - `confirmarEliminarCliente` → dispatch ELIMINAR_CLIENTE, cierra modal, toast "✓ Cliente eliminado"  
  - `confirmarEliminarValor` → dispatch ELIMINAR_VALOR_SELECCIONADO, cierra modal, toast "✓ Valor eliminado"  
  - `confirmarReiniciar` → dispatch RESTORE con payload vacío, cierra modal, toast "✓ Datos reiniciados"
- **Modales renderizados en App.js:**  
  - `ModalNuevoCliente`, `ModalValores`, tres usos de `ModalConfirmar` (eliminar cliente, eliminar valor, reiniciar), `Toast`.

---

## 6. Pantallas

### InicioScreen

- **Props:** `onAbrirNuevoCliente`, `onAbrirValores`, `onAbrirReiniciar`.
- **Contenido:**  
  - Header: botón “+” (person-add) para nuevo cliente, título "Clientes", placeholder a la derecha (sin botón eliminar aquí).  
  - Lista (ScrollView) de clientes: cada ítem muestra nombre, "Total: $X", "Cantidad: N"; al tocar se llama `onAbrirValores(nombre)`. El cliente seleccionado tiene estilo resaltado.  
  - Fila inferior: bloque "Total General: $X" a la izquierda y botón "Reiniciar" a la derecha; al tocar Reiniciar se llama `onAbrirReiniciar()`.
- **Datos:** `ordenClientes`, `state.clientes`, `totalGeneral` vía `useApp()`.

### TablaScreen

- **Props:** `onAbrirEliminarValor`.
- **Contenido:**  
  - Header: título "Tabla de Clientes" y botón que muestra "Eliminar Valor" o "Eliminar $X (Nombre)" según haya valor seleccionado; al tocar se llama `onAbrirEliminarValor()` (solo tiene efecto si hay selección).  
  - Tabla con scroll horizontal y vertical: fila de cabecera (Nombre, V1, V2, …, Total), luego una fila por cliente con nombre, celdas de valores (tocables para seleccionar) y celda Total. Valores marcados como detalle se muestran entre paréntesis. Filas alternadas (even/odd), fila y celda seleccionadas con estilo distinto.  
- **Lógica:** `maxValores` = máximo de cantidades de valores por cliente (limitado a 100). Al tocar una celda con valor se hace `dispatch(SELECCIONAR_VALOR_TABLA, { nombre, indice })`.

---

## 7. Componentes

### ModalNuevoCliente

- **Props:** `visible`, `onCerrar`, `onAgregar`.
- **Comportamiento:** Modal con título "Nuevo Cliente", botón cerrar (✕), campo "Nombre del Cliente", campo "Valor Inicial" (numérico), botón "+ Agregar Cliente". Al agregar: valida nombre no vacío y valor numérico, llama `onAgregar(nombre, valor)`, limpia campos y `onCerrar()`. Usa `KeyboardAvoidingView` para iOS.

### ModalValores

- **Props:** `visible`, `nombreCliente`, `onCerrar`, `onAgregarValor`, `onToast`, `onEliminarCliente`.
- **Comportamiento:**  
  - Header: botón eliminar cliente (icono trash, rojo), título = solo `nombreCliente`, botón cerrar (✕). Al tocar eliminar se llama `onEliminarCliente()` (en App.js eso cierra este modal y abre el de confirmar eliminar cliente).  
  - Switch "Detalle:" que afecta al siguiente valor agregado.  
  - Grid de botones con `VALORES_BOTONES` (0, 500, 1000, …, 5500). Al tocar uno se llama `onAgregarValor(valor, detalle)` y `onToast('Valor agregado: ' + formatMoney(valor), 'agregado')`.  
  - Input "Otro valor" + botón "+" para añadir un valor numérico custom (misma lógica de agregar + toast).

### ModalConfirmar

- **Props:** `visible`, `titulo`, `onCancelar`, `onConfirmar`.
- **Comportamiento:** Modal con título centrado y dos botones: rojo con ✕ (cancelar), verde con ✓ (confirmar). Se reutiliza para: eliminar cliente, eliminar valor, reiniciar datos.

### Toast

- **Props:** `visible`, `text`, `tipo` ('agregado' | 'eliminado'), `onHide`.
- **Comportamiento:** Overlay con caja de texto. Si `tipo === 'eliminado'` la caja es naranja (warning), si no verde (success). Se auto-oculta a los 1000 ms llamando `onHide()`.

---

## 8. Tema y utilidades

- **theme.js:**  
  - `colors`: bg, card, input, border, text, textMuted, primary, primaryHover, success, danger, warning, totalBadge, selected.  
  - `VALORES_BOTONES`: [0, 500, 1000, …, 5500].
- **formatMoney(n):** devuelve `'$' + Number(n).toLocaleString('es')`.

---

## 9. Flujos de usuario (resumen)

1. **Agregar cliente:** Inicio → botón + → ModalNuevoCliente → nombre y valor → Agregar → se guarda en estado y AsyncStorage, modal se cierra.  
2. **Ver/agregar valores:** Inicio → tocar un cliente → ModalValores (título = nombre). Ahí se agregan valores (botones o “Otro valor”); cada uno puede marcarse como detalle con el switch. Toast "Valor agregado: $X" 1 s.  
3. **Eliminar cliente:** Desde ModalValores → botón papelera → se cierra modal y se abre ModalConfirmar "¿Desea eliminar a X?" → Confirmar → cliente eliminado, toast "✓ Cliente eliminado".  
4. **Eliminar valor:** Tabla → tocar una celda con valor (queda seleccionada) → botón "Eliminar $X (Nombre)" → ModalConfirmar "¿Seguro que desea eliminar el valor?" → Confirmar → valor eliminado, toast "✓ Valor eliminado".  
5. **Reiniciar:** Inicio → botón "Reiniciar" → ModalConfirmar "¿Está seguro de eliminar todos los datos?" → Confirmar → RESTORE vacío, datos borrados y guardados en AsyncStorage, toast "✓ Datos reiniciados".

---

## 10. Funcionalidades (lista cerrada)

- Alta de clientes con nombre y valor inicial.  
- Lista de clientes ordenada por actividad reciente, con total y cantidad por cliente.  
- Total general visible en Inicio.  
- Modal de valores por cliente: título = nombre del cliente, botón eliminar cliente a la izquierda del título, switch Detalle, botones de valor 0–5500, “Otro valor” + botón +.  
- Valores normales vs “detalle” (en tabla se muestran entre paréntesis).  
- Tabla de clientes con columnas Nombre, V1…Vn, Total; scroll horizontal y vertical; selección de celda para eliminar valor.  
- Eliminar cliente (solo desde modal Valores) con confirmación.  
- Eliminar valor (solo desde Tabla) con confirmación.  
- Reiniciar todos los datos con confirmación.  
- Toasts breves (1 s) para valor agregado, cliente eliminado, valor eliminado, datos reiniciados.  
- Persistencia en AsyncStorage; datos sobreviven al cerrar la app.  
- Orientación automática (default).  
- Iconos Ionicons en tabs (Inicio, Tabla) y en botones (person-add, trash).  
- Tema oscuro (colors en theme.js).

---

## 11. Dependencias relevantes (package.json)

- expo ^54.0.0  
- react 19.1.0, react-native 0.81.5  
- @react-navigation/native, @react-navigation/bottom-tabs  
- @react-native-async-storage/async-storage  
- react-native-screens, react-native-safe-area-context  
- expo-status-bar  
- devDependencies: @babel/core, babel-preset-expo  

No hay backend: todo es local (estado + AsyncStorage). Compatible con Expo Go para desarrollo y pruebas; APK se puede generar con EAS Build o prebuild + Gradle.
