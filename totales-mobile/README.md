# Gestión de Clientes - Totales (versión móvil / Android)

Aplicación web **responsiva** con la **misma funcionalidad** que la app de escritorio, optimizada para **tablets y smartphones Android** (y cualquier navegador en móvil).

---

## Cómo instalar en teléfono y tablet

La app es una **página web**, no un archivo .apk. Para usarla en el móvil o la tablet hay que abrirla en el navegador y, si quieres, **añadirla a la pantalla de inicio** para que funcione como una app.

### Método recomendado: servidor en tu red WiFi

**En el PC (donde está la carpeta del proyecto):**

1. Abre una terminal en la carpeta **`totales-mobile`** (donde están `index.html`, `styles.css` y `app.js`).
2. Ejecuta:
   ```bash
   python -m http.server 8080
   ```
   (Si no tienes Python, instálalo desde [python.org](https://www.python.org/downloads/) o usa `npx serve .` si tienes Node.js.)
3. Anota la **IP de tu PC**:
   - **Windows:** abre CMD o PowerShell y escribe `ipconfig`. Busca "Dirección IPv4" (ej: `192.168.1.10`).
   - **Mac:** en Terminal, `ifconfig` o en Preferencias del Sistema → Red.

**En el teléfono o la tablet:**

4. Conéctate a la **misma red WiFi** que el PC.
5. Abre **Chrome** (o Firefox, Samsung Internet, etc.).
6. En la barra de direcciones escribe: **`http://IP_DEL_PC:8080`**  
   Ejemplo: `http://192.168.1.10:8080`
7. Se abrirá la aplicación.

**Para “instalarla” como app (icono en la pantalla de inicio):**

8. En Chrome: menú (⋮) → **“Añadir a la pantalla de inicio”** o **“Instalar aplicación”**.
9. En otros navegadores: suele estar en el menú como **“Añadir a inicio”** o **“Crear acceso directo”**.

A partir de ahí puedes abrir la app desde el icono. **Importante:** el PC debe seguir encendido y con el comando `python -m http.server 8080` en ejecución, y el móvil/tablet en la misma WiFi, para que cargue.

### Alternativa: subirla a internet

Si quieres usarla sin depender del PC:

1. Sube la carpeta `totales-mobile` (o solo `index.html`, `styles.css` y `app.js`) a un hosting gratuito como **Netlify**, **Vercel** o **GitHub Pages**.
2. Obtendrás una URL (ej: `https://mi-app.netlify.app`).
3. Abre esa URL en el navegador del teléfono o la tablet.
4. Añade la página a la pantalla de inicio como en los pasos 8–9 anteriores.

Así la app funcionará desde cualquier sitio con internet, sin tener el PC encendido.

### Resumen

| Qué quieres | Qué hacer |
|------------|-----------|
| Usar en casa (PC + mismo WiFi) | Servidor en PC con `python -m http.server 8080` y abrir `http://IP_PC:8080` en el móvil/tablet. |
| Usar en cualquier lugar | Subir los archivos a Netlify/Vercel/GitHub Pages y abrir la URL en el navegador. |
| Icono como una app | En el navegador del dispositivo: menú → “Añadir a la pantalla de inicio” / “Instalar aplicación”. |

**¿Quieres un archivo APK?** Ver [COMO_OBTENER_APK.md](COMO_OBTENER_APK.md).

---

## Funcionalidades (igual que la app de escritorio)

- Agregar cliente (nombre + valor inicial).
- Total general de todos los clientes.
- Tabla de clientes con columnas Nombre, Valor 1…Valor N, Total.
- Lista de clientes: seleccionar uno para agregarle valores.
- Checkbox **Detalle**: si está marcado, el valor se muestra entre paréntesis en la tabla.
- Botones de valores: 0, 500, 1000, 1500, 2000, 2500, 3000, 3500.
- Valor personalizado (campo + botón +).
- Eliminar cliente seleccionado.
- Eliminar último valor del cliente seleccionado.
- Seleccionar un valor en la tabla (clic en una celda) y eliminarlo con "Eliminar Valor".
- Totales y cantidad por cliente en la lista.

## Cómo usarla en Android

### Opción 1: Abrir desde un servidor en la red (recomendado)

1. En tu PC, sirve la carpeta con un servidor local, por ejemplo:
   - Con Python: `python -m http.server 8080` (desde la carpeta `totales-mobile`).
   - Con Node: `npx serve .` o `npx http-server -p 8080`.
2. Anota la IP de tu PC (en Windows: `ipconfig`, busca "Dirección IPv4").
3. En el **teléfono o tablet Android**, abre Chrome (o cualquier navegador).
4. Escribe en la barra de direcciones: `http://TU_IP:8080` (ej: `http://192.168.1.10:8080`).
5. Deberías ver la aplicación. Puedes añadirla a la pantalla de inicio: menú del navegador → "Añadir a pantalla de inicio" / "Instalar aplicación".

### Opción 2: Subir a un hosting web

1. Sube los archivos `index.html`, `styles.css` y `app.js` a cualquier hosting (Netlify, GitHub Pages, tu propio servidor, etc.).
2. Abre la URL desde el navegador del Android.

### Opción 3: Abrir el archivo local en el móvil

1. Copia la carpeta `totales-mobile` al dispositivo Android (por USB, Google Drive, etc.).
2. Abre el archivo `index.html` con un navegador (Chrome, Firefox).  
   **Nota:** Algunos navegadores pueden restringir JavaScript en archivos locales; si algo no funciona, usa la Opción 1 o 2.

## Cómo ejecutarla en el PC (pruebas)

Desde la carpeta `totales-mobile`:

```bash
# Con Python 3
python -m http.server 8080

# Luego abre en el navegador: http://localhost:8080
```

O abre directamente `index.html` con doble clic (funciona en la mayoría de navegadores para pruebas básicas).

## Diseño responsivo

- **Escritorio:** Dos columnas (Clientes | Valores), tabla amplia.
- **Tablet (≤ 1024px):** Una columna, formularios apilados, tabla con scroll horizontal.
- **Smartphone (≤ 600px):** Botones y campos a ancho completo, tabla con scroll horizontal, columnas de valores más estrechas, teclado numérico en inputs numéricos (`inputmode="numeric"`).
- **Pantallas muy pequeñas (≤ 380px):** Botones de valores en una sola columna.

Incluye soporte para **safe area** (notch/islas) y **viewport** adecuado para que no haga zoom no deseado en iOS/Android.

## Archivos

- `index.html` – Estructura de la aplicación.
- `styles.css` – Estilos y diseño responsivo (tema oscuro).
- `app.js` – Lógica (clientes, valores, totales, detalle, tabla).

No requiere instalación de nada en el dispositivo: solo un navegador actual (Chrome, Firefox, Samsung Internet, etc.) en Android.
