# Totales — React Native (Expo)

Clon de la aplicación **Totales** para móvil, desarrollado con **React Native** y **Expo**. Misma funcionalidad que la versión web: gestión de clientes, valores por cliente, totales y tabla resumen.

## Requisitos

- Node.js (v18 o superior recomendado)
- npm o yarn
- Para probar en dispositivo: Expo Go (Android/iOS) o emulador

## Instalación

```bash
cd totales-react-native
npm install
```

## Ejecutar la aplicación

```bash
npx expo start
```

- **Android:** Pulsa `a` en la terminal o escanea el código QR con Expo Go.
- **iOS:** Pulsa `i` en la terminal (simulador) o escanea el código QR con la cámara/Expo Go.

## Estructura

- `App.js` — Punto de entrada: navegación (pestañas Inicio / Tabla), modales y toasts.
- `src/context/AppContext.js` — Estado global (clientes, detalles, selecciones).
- `src/screens/InicioScreen.js` — Lista de clientes, total general, botones nuevo/eliminar.
- `src/screens/TablaScreen.js` — Tabla de clientes con valores y eliminación de valor seleccionado.
- `src/components/` — Modales (Nuevo Cliente, Valores, Confirmar) y Toast.

## Funcionalidades

- **Inicio:** Añadir cliente (modal), abrir valores de un cliente (modal), eliminar cliente (confirmación), ver total general.
- **Tabla:** Ver todos los clientes y sus valores en tabla; seleccionar un valor y eliminarlo con confirmación.
- Toasts para valor agregado, valor eliminado y cliente eliminado.

## ¿Funciona solo con Expo Go?

Sí. La app usa únicamente dependencias soportadas por **Expo Go** (navegación, AsyncStorage, iconos, componentes estándar). No requiere development build; puedes usarla al 100 % escaneando el QR con Expo Go.

## Obtener una APK (Android)

Para instalar la app en Android sin Expo Go necesitas generar un APK.

**Opción 1 – EAS Build (recomendado):** Instala `eas-cli` (`npm install -g eas-cli`), haz `eas login` y en el proyecto ejecuta `eas build --platform android --profile preview`. El APK se podrá descargar desde el enlace que muestra el comando o desde expo.dev en la pestaña Builds.

**Opción 2 – Build local:** Ejecuta `npx expo prebuild --platform android` y luego `cd android && ./gradlew assembleRelease`. El APK queda en `android/app/build/outputs/apk/release/app-release.apk`. Necesitas Android SDK y JAVA_HOME/ANDROID_HOME configurados.
