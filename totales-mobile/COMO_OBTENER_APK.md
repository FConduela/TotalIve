# Cómo obtener un APK de esta app

Esta app es una **página web** (HTML/CSS/JS). Para tener un archivo **.apk** que puedas instalar en Android hay dos caminos:

---

## Opción 1: Capacitor (recomendada si quieres el APK en tu PC)

Con **Capacitor** empaquetas la web dentro de una app Android y generas el APK en tu computador. Necesitas **Node.js** y **Android Studio**.

### Requisitos

- **Node.js** instalado ([nodejs.org](https://nodejs.org))
- **Android Studio** instalado ([developer.android.com/studio](https://developer.android.com/studio)) — para compilar el APK
- La carpeta **totales-mobile** con `index.html`, `styles.css`, `app.js`, `package.json` y `capacitor.config.json`

### Pasos

1. **Abre una terminal** en la carpeta **totales-mobile** (donde está este README).

2. **Instala Capacitor y añade Android:**
   ```bash
   npm install @capacitor/core @capacitor/cli @capacitor/android
   npx cap add android
   ```

3. **Copia la web al proyecto Android:**
   ```bash
   npx cap sync
   ```

4. **Abre el proyecto en Android Studio:**
   ```bash
   npx cap open android
   ```
   Se abrirá la carpeta `android` en Android Studio.

5. **Generar el APK en Android Studio:**
   - Menú **Build** → **Build Bundle(s) / APK(s)** → **Build APK(s)**  
     O para una versión lista para instalar en cualquier dispositivo (release):
   - **Build** → **Generate Signed Bundle / APK** → elige **APK** → crea o elige un keystore (contraseña para firmar la app) → **release**.
   - Al terminar, Android Studio te indicará la ruta del APK (suele ser `android/app/build/outputs/apk/release/app-release.apk`).

6. **Pasar el APK al móvil/tablet:**  
   Copia el archivo `.apk` por USB, Google Drive, correo, etc., e instálalo en el dispositivo (puede que tengas que permitir “Instalar desde fuentes desconocidas” en Ajustes).

### Resumen de comandos (en la carpeta totales-mobile)

```bash
npm install @capacitor/core @capacitor/cli @capacitor/android
npx cap add android
npx cap sync
npx cap open android
```

Luego en Android Studio: **Build → Build Bundle(s) / APK(s) → Build APK(s)** (o **Generate Signed Bundle / APK** para el APK de release).

---

## Opción 2: PWA Builder (si ya tienes la app publicada en una URL)

Si la app está **colgada en internet** (Netlify, Vercel, tu propio servidor, etc.), puedes usar **PWA Builder** de Microsoft para generar un paquete Android (y a partir de ahí un APK o AAB).

1. **Sube antes la app** a Netlify, Vercel, GitHub Pages, etc., y anota la URL (ej: `https://totales.netlify.app`).

2. Entra en **[pwabuilder.com](https://www.pwabuilder.com)**.

3. Pega la **URL de tu app** y pulsa “Start”.

4. Si la página cumple requisitos de PWA, te permitirá **packaging** para **Android**. Sigue los pasos para descargar el paquete Android.

5. Para obtener un **APK** a partir de ese paquete suele hacer falta compilar el proyecto Android que te dan (por ejemplo con Android Studio) o usar la opción que PWA Builder indique para “Download” del APK si la ofrecen.

**Nota:** Para que PWA Builder la detecte bien como instalable, la app debería tener un **manifest** y, si es posible, HTTPS. Si más adelante quieres, se puede añadir un `manifest.json` a esta misma carpeta para mejorar la instalación y el uso con PWA Builder.

---

## Comparación rápida

| | Capacitor | PWA Builder |
|---|-----------|-------------|
| **Necesitas** | Node.js, Android Studio, proyecto en tu PC | App publicada en una URL |
| **Ventaja** | APK generado por ti, sin depender de un servicio externo | No hace falta Android Studio si solo usas su flujo web |
| **Resultado** | Archivo .apk en tu PC | Paquete/APK según lo que ofrezca PWA Builder |

Si tienes Node.js y Android Studio (o estás dispuesto a instalarlos), la **Opción 1 (Capacitor)** es la más directa para **obtener el APK** desde esta misma carpeta.
