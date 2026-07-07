# Totales (Flutter)

Versión Flutter de la app de totales por cliente, cierre de jornada (bolsas) y gestión de envíos pendientes. Misma lógica que `totales-react-native` (persistencia en `shared_preferences`, sincronización opcional al cerrar jornada).

## Requisitos

- Flutter instalado y en el `PATH` (comandos `flutter` y `dart`).
- **Windows:** ver la guía oficial [Instalar Flutter en Windows](https://docs.flutter.dev/get-started/install/windows) (resumen abajo en este README).
- **iPhone:** compilar para iOS solo es posible en **macOS** con Xcode (o con CI en la nube). En Windows puedes desarrollar y probar en **Android** o en **Chrome** (`flutter run -d chrome`).

## Instalar Flutter en Windows (resumen)

1. Instala [Git for Windows](https://git-scm.com/download/win) si aún no lo tienes.
2. Descarga el SDK **stable** en ZIP desde la página de instalación de Flutter (enlace arriba) o desde el [archivo de versiones](https://docs.flutter.dev/release/archive?tab=windows).
3. Extrae el ZIP en una ruta **sin espacios ni caracteres raros**, por ejemplo `C:\src\flutter` (no uses `C:\Program Files\`).
4. Añade `C:\src\flutter\bin` (o la ruta donde quedó `bin`) al **PATH** del usuario: *Configuración → Sistema → Acerca de → Configuración avanzada del sistema → Variables de entorno* → en “Variables del usuario” edita `Path` → *Nuevo* → pega la ruta a `flutter\bin`.
5. Abre una **nueva** PowerShell o CMD y ejecuta `flutter doctor`. Instala lo que marque como faltante (p. ej. Android Studio para el SDK de Android).
6. Acepta licencias de Android: `flutter doctor --android-licenses`.
7. Comprueba de nuevo: `flutter doctor` hasta que no queden errores críticos para lo que vayas a usar.

## Generar carpetas Android e iOS

Este directorio incluye el código en `lib/` y `pubspec.yaml`. Las carpetas `android/` e `ios/` se generan con el SDK de Flutter **sin borrar** tu `lib` si ejecutas desde aquí:

```bash
cd totales_flutter
flutter create .
flutter pub get
flutter run
```

Configura la URL del script en `lib/config.dart` (`syncCierreJornadaUrl`).

## Estructura principal

- `lib/app_state.dart` — estado y persistencia.
- `lib/app_shell.dart` — pestañas, modales y confirmaciones.
- `lib/screens/` — Inicio, Tabla, Envíos.
- `lib/services/sync_service.dart` — POST al cerrar jornada.
