# Google Apps Script + Google Sheets

Registra en la nube los cierres de jornada que envía la app Flutter.

## Qué guarda

### Pestaña **Cierres** (al cerrar jornada en Inicio)

| Fecha | Cliente | Cantidad Productos | Monto Total | Registrado |

### Pestaña **Envios** (al cerrar totales, pagar o despachar)

| Fecha | Estado | Cliente | Jornada | Paquetes | Artículos | Monto | Registrado |

Estados en la pestaña Envios:
- **Pendiente** — al presionar "Cerrar Totales"
- **Pagado** — al registrar un pago
- **Despachado** — al despachar paquetes

## Configuración paso a paso

### 1. Crear la hoja de cálculo

1. Entra a [Google Sheets](https://sheets.google.com).
2. Crea una hoja nueva (por ejemplo: **Totales Jugandotoy**).
3. No hace falta crear columnas manualmente: el script las crea al primer cierre.

### 2. Crear el script

1. En la hoja: **Extensiones → Apps Script**.
2. Borra el contenido por defecto.
3. Copia y pega todo el archivo `Code.gs` de esta carpeta.
4. Guarda el proyecto (Ctrl+S).

### 3. Probar (opcional)

1. En Apps Script, ejecuta `probarCierre` y luego `probarEnvio`.
2. Pulsa **Ejecutar** en cada una.
3. Autoriza permisos la primera vez.
4. Revisa las pestañas **Cierres** y **Envios** en tu hoja.

### 4. Publicar como Web App

1. **Implementar → Nueva implementación**.
2. Tipo: **Aplicación web**.
3. Ejecutar como: **Yo**.
4. Quién tiene acceso: **Cualquiera** (la app móvil no inicia sesión en Google).
5. **Implementar** y copia la URL que termina en `/exec`.

### 5. Conectar la app Flutter

1. Abre `totales_flutter/lib/config.dart`.
2. Reemplaza `YOUR_SCRIPT_ID` por la URL completa que copiaste:

```dart
const String syncCierreJornadaUrl =
    'https://script.google.com/macros/s/TU_SCRIPT_ID_AQUI/exec';
```

3. Vuelve a compilar o ejecutar la app.

## Notas

- La sincronización es **opcional**: si falla la red, la app sigue funcionando con datos locales.
- Solo se sincroniza al **Cerrar Jornada** (pestaña Cierres), **Cerrar Totales** (Pendiente), **Pagar** (Pagado) y **Despachar** (Despachado).
- Los datos principales de la app siguen guardándose en el teléfono (`SharedPreferences`).

## Archivos relacionados en Flutter

- `lib/config.dart` — URL del Web App
- `lib/services/sync_service.dart` — envío del POST
- `lib/app_state.dart` — llama al sync en cerrar jornada, cerrar totales, pagos y despachos
