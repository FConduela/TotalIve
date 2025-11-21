# Gestión de Clientes - Totales

Aplicación moderna de escritorio para gestionar clientes y calcular sus totales de valores.

## Características

- ✨ Interfaz moderna con CustomTkinter
- 📊 Tabla interactiva para visualizar clientes y valores
- 💰 Gestión de valores con botones predefinidos y valores personalizados
- 🎨 Tema oscuro moderno
- 📱 Diseño responsivo

## Requisitos del Sistema

### Requisitos Mínimos:
- **Python 3.7 o superior** (recomendado Python 3.8+)
- **Sistema Operativo**: Windows, macOS o Linux
- **Memoria RAM**: Mínimo 512 MB
- **Espacio en disco**: ~50 MB

### Dependencias:
- `customtkinter >= 5.2.0`

## Instalación en un Nuevo Computador

### Paso 1: Instalar Python

Si Python no está instalado:

**Windows:**
1. Descarga Python desde [python.org](https://www.python.org/downloads/)
2. Durante la instalación, marca la opción "Add Python to PATH"
3. Verifica la instalación abriendo PowerShell/CMD y ejecutando:
   ```bash
   python --version
   ```

**macOS:**
```bash
# Usando Homebrew
brew install python3

# O descarga desde python.org
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3 python3-pip
```

### Paso 2: Copiar los Archivos

Copia los siguientes archivos a la nueva computadora:
- `app.py`
- `requirements.txt`
- `README.md` (opcional)

### Paso 3: Instalar Dependencias

Abre una terminal/consola en la carpeta del proyecto y ejecuta:

```bash
pip install -r requirements.txt
```

O si prefieres instalar directamente:
```bash
pip install customtkinter
```

**Nota para Windows:** Si `pip` no funciona, prueba con:
```bash
python -m pip install -r requirements.txt
```

**Nota para Linux/macOS:** Puede que necesites usar `pip3`:
```bash
pip3 install -r requirements.txt
```

### Paso 4: Ejecutar la Aplicación

```bash
python app.py
```

O en algunos sistemas:
```bash
python3 app.py
```

## Crear un Ejecutable (Archivo .exe para Windows)

Si quieres crear un archivo ejecutable que puedas copiar a cualquier computador sin necesidad de instalar Python:

### Opción 1: Usando el Script Automático (Windows)

1. Ejecuta el archivo `build_executable.bat` haciendo doble clic
2. Espera a que termine el proceso
3. El ejecutable estará en la carpeta `dist` con el nombre `GestionClientes.exe`
4. Copia ese archivo .exe a cualquier computador y ejecútalo directamente

### Opción 2: Manualmente con PyInstaller

1. **Instalar PyInstaller:**
   ```bash
   pip install pyinstaller
   ```

2. **Crear el ejecutable:**
   
   **Windows:**
   ```bash
   pyinstaller --onefile --windowed --name "GestionClientes" app.py
   ```
   
   **macOS/Linux:**
   ```bash
   pyinstaller --onefile --windowed --name "GestionClientes" app.py
   ```

3. **Encontrar el ejecutable:**
   - El archivo estará en la carpeta `dist/`
   - Windows: `dist/GestionClientes.exe`
   - macOS/Linux: `dist/GestionClientes`

### Ventajas del Ejecutable

✅ **No requiere Python instalado** en el computador destino  
✅ **No requiere instalar dependencias**  
✅ **Un solo archivo** fácil de copiar y compartir  
✅ **Ejecución directa** con doble clic  

### Notas sobre el Ejecutable

- El archivo .exe puede ser grande (~30-50 MB) porque incluye Python y todas las dependencias
- La primera ejecución puede tardar unos segundos
- Algunos antivirus pueden marcar el .exe como sospechoso (falso positivo), es normal con PyInstaller
- El ejecutable es específico del sistema operativo (Windows .exe no funciona en macOS/Linux)

## Uso

## Funcionalidades

- **Agregar Cliente**: Ingresa un nombre y un valor inicial para crear un nuevo cliente
- **Seleccionar Cliente**: Haz clic en el botón del cliente para seleccionarlo
- **Agregar Valores**: Usa los botones de valores predefinidos o ingresa valores personalizados
- **Eliminar Cliente**: Elimina el cliente seleccionado
- **Eliminar Valores**: Elimina el último valor o un valor específico seleccionado en la tabla
- **Visualización**: La tabla muestra todos los valores y el total de cada cliente

## Notas

- Los valores se formatean con separadores de miles (ej: $1,000)
- La aplicación se maximiza automáticamente al iniciar
- El tema oscuro se puede cambiar en el código modificando `ctk.set_appearance_mode()`

