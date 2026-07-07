# Contexto completo de la aplicación "Gestión de Clientes - Totales" (Totales Jugandotoy)

Documento para dar contexto a otra IA sobre el proyecto, su arquitectura, funcionalidades y detalles técnicos.

---

## 1. Resumen ejecutivo

**Nombre del proyecto:** Totales Jugandotoy (título de ventana: "Gestión de Clientes - Totales")

**Tipo:** Aplicación de escritorio (desktop) en Python.

**Propósito:** Gestionar una lista de clientes, cada uno con una lista de valores numéricos (montos), calcular totales por cliente y un total general. Pensada para llevar control de ventas/pedidos por cliente con valores que pueden marcarse como "detalle" (mostrados entre paréntesis en la tabla).

**Tecnologías:** Python 3.7+, CustomTkinter (tema oscuro), Tkinter estándar (ttk para Treeview).

---

## 2. Estructura del proyecto

```
Totales Jugandotoy/
├── app.py                    # Código principal: una sola clase y main
├── requirements.txt          # customtkinter>=5.2.0
├── README.md                 # Documentación de uso e instalación
├── CONTEXTO_APLICACION_PARA_IA.md  # Este archivo
├── build_executable.bat      # Script Windows para generar .exe con PyInstaller
├── build_executable.sh       # Script Unix para generar ejecutable
├── CREAR_EJECUTABLE.bat      # Alternativa para crear ejecutable
├── INSTRUCCIONES_EJECUTABLE.txt  # Instrucciones para crear el .exe
└── .gitignore
```

No hay bases de datos ni archivos de configuración externos: todo el estado vive en memoria mientras la app está abierta.

---

## 3. Modelo de datos (en memoria)

- **`self.clientes`**: `dict[str, list[int]]`  
  Clave = nombre del cliente. Valor = lista de valores (números enteros).

- **`self.detalles`**: `dict[str, list[bool]]`  
  Misma clave que `clientes`. Cada posición indica si el valor en esa posición es "detalle" (True) o no (False). Se usa para mostrar ese valor entre paréntesis en la tabla.

- **`self.cliente_seleccionado`**: `str | None`  
  Nombre del cliente actualmente seleccionado (para agregar valores o eliminar).

- **`self.valor_seleccionado`**: `int | None`  
  Índice del valor seleccionado en la tabla (para "Eliminar Valor" del cliente seleccionado).

- **`self.botones_clientes`**: `dict[str, CTkButton]`  
  Referencias a los botones de la lista de clientes (panel izquierdo).

- **`self.labels_totales`**: `dict[str, CTkLabel]`  
  Labels que muestran "Total: $X" por cliente.

- **`self.labels_cantidad`**: `dict[str, CTkLabel]`  
  Labels que muestran "Cantidad: N" (número de valores) por cliente.

---

## 4. Interfaz de usuario (UI)

### 4.1 Configuración general

- **Tema:** Oscuro (`ctk.set_appearance_mode("dark")`).
- **Tema de color:** Azul (`ctk.set_default_color_theme("blue")`).
- **Ventana:** 1000x700, mínima 700x500, se intenta maximizar al iniciar (`zoomed` en Windows, fallback a geometry de pantalla completa).

### 4.2 Secciones de la ventana (de arriba a abajo)

1. **Sección "Nuevo Cliente"**
   - Campos: "Nombre del Cliente", "Valor Inicial".
   - Botón: "+ Agregar Cliente".
   - Label a la derecha: "Total General: $X" (suma de todos los valores de todos los clientes).
   - Enter en nombre o valor ejecuta agregar cliente.

2. **Tabla de clientes**
   - Treeview con columnas: **Nombre** + **Valor 1** … **Valor 100** + **Total**.
   - Cada fila = un cliente; celdas con valores formateados como `$1,234` o `($1,234)` si es detalle.
   - Columna Total = suma de los valores de esa fila.
   - Estilo: fondo oscuro, encabezados azules, selección verde.
   - Clic en una celda de valor: selecciona ese cliente y ese valor (para "Eliminar Valor").
   - Indicador arriba a la derecha de la tabla: muestra "Valor seleccionado: $X (Cliente: Y)" cuando hay un valor seleccionado.

3. **Dos paneles inferiores (lado a lado)**
   - **Panel izquierdo – Clientes**
     - Título "Clientes" y botón "Eliminar Cliente".
     - Lista scrollable de botones: un botón por cliente con su nombre. Al lado de cada uno: label "Total: $X" y "Cantidad: N". El cliente seleccionado se muestra con "✓" y color verde.
   - **Panel derecho – Valores**
     - Checkbox "Detalle" (si está marcado, el próximo valor agregado se guarda como detalle).
     - Título "Valores" y botones "Eliminar Ultimo" y "Eliminar Valor".
     - Botones de valores fijos: 0, 500, 1000, 1500, 2000, 2500, 3000, 3500 (en grid 2 columnas).
     - Campo "Valor personalizado..." + botón "+" para agregar ese número. Enter en el campo agrega el valor personalizado.

---

## 5. Funcionalidades (flujos)

### 5.1 Agregar cliente

- **Método:** `_agregar_cliente()`.
- **Condiciones:** Nombre no vacío, valor inicial numérico, nombre no existente.
- **Acción:** Crea entrada en `clientes[nombre] = [valor]` y `detalles[nombre] = [False]`. Crea en el panel izquierdo: frame + botón (nombre) + label total + label cantidad. Actualiza tabla y total general. Limpia campos nombre y valor.

### 5.2 Seleccionar cliente

- **Método:** `_seleccionar_cliente(nombre)` (desde botón del panel izquierdo).
- **Acción:** `cliente_seleccionado = nombre`, luego `_actualizar_botones_clientes()` para resaltar el seleccionado (✓ y color verde).

### 5.3 Agregar valor al cliente seleccionado

- **Métodos:** `_agregar_valor_a_cliente(valor)` (botones fijos) y `_agregar_valor_personalizado()` (campo + Enter/botón "+").
- **Condición:** Hay cliente seleccionado.
- **Acción:** Se hace append del valor a `clientes[cliente_seleccionado]` y de `detalle_var.get()` a `detalles[cliente_seleccionado]`. Se desmarca el checkbox Detalle. Se actualizan botones, tabla y total general. Valor personalizado: se parsea como int; si falla, no se hace nada.

### 5.4 Eliminar cliente

- **Método:** `_eliminar_cliente()`.
- **Condición:** Hay cliente seleccionado.
- **Acción:** Borra de `clientes`, `detalles`, destruye el frame del botón en el panel izquierdo, borra de `botones_clientes`, `labels_totales`, `labels_cantidad`. Limpia `cliente_seleccionado`. Actualiza tabla y total general.

### 5.5 Eliminar último valor

- **Método:** `_eliminar_ultimo_valor()`.
- **Condición:** Hay cliente seleccionado y al menos un valor.
- **Acción:** `pop()` en la lista de valores y en la lista de detalles del cliente. Si la lista de valores queda vacía, se llama `_eliminar_cliente()`. Si no, se actualizan botones y tabla.

### 5.6 Selección de valor en la tabla y eliminar valor seleccionado

- **Clic en tabla:** `_on_tabla_click(event)`. Si la celda es de una columna de valor (Valor1…Valor100) y hay valor en esa celda, se asigna `valor_seleccionado = índice` y se selecciona el cliente de esa fila si no estaba seleccionado. Se actualiza el indicador "Valor seleccionado: $X (Cliente: Y)".
- **Eliminar valor:** `_eliminar_valor_seleccionado()`. Elimina el valor en `valor_seleccionado` del cliente seleccionado (y el detalle en el mismo índice). Si no quedan valores, elimina el cliente. Limpia indicador y selección; actualiza botones y tabla.

### 5.7 Actualización de tabla

- **Método:** `_actualizar_tabla()`.
- Se borran todas las filas del Treeview. Para cada cliente se construye una fila: nombre + hasta 100 celdas (valor formateado `$n` o `($n)` si es detalle, o vacío) + total. Los valores se formatean con separador de miles (ej. `$1,000`).

### 5.8 Totales

- **Total por cliente:** Suma de `clientes[nombre]`; se muestra en el label del panel y en la columna "Total" de la tabla.
- **Total general:** Suma de todos los valores de todos los clientes; se actualiza en `_actualizar_total_general()` y se muestra en el header "Nuevo Cliente".

---

## 6. Detalles técnicos relevantes

- **CustomTkinter:** Se usa para ventana principal, frames, labels, entries, botones, scrollable frames. La tabla es **ttk.Treeview** (Tk estándar) con estilo "clam" y colores manuales para integrarla al tema oscuro.
- **Tabla:** 100 columnas de valores (Valor1…Valor100) fijas; no se crean/eliminan columnas dinámicamente.
- **Persistencia:** No hay guardado/carga; al cerrar la app se pierde todo.
- **Atajos:** Enter en nombre o valor inicial → agregar cliente. Enter en valor personalizado → agregar valor personalizado.
- **Responsividad:** Se usan `grid_columnconfigure`/`grid_rowconfigure` con weight para que los paneles y la tabla se expandan.

---

## 7. Creación de ejecutable

- **Windows:** `build_executable.bat` o `CREAR_EJECUTABLE.bat` ejecutan PyInstaller para generar un solo .exe sin consola: `PyInstaller --onefile --windowed --name "GestionClientes" --clean app.py`. Salida en `dist/GestionClientes.exe`.
- **Dependencia extra para build:** `pyinstaller` (no está en requirements.txt; se instala al ejecutar el script).
- El ejecutable es independiente de Python en la máquina destino; tamaño típico 30–50 MB.

---

## 8. Resumen para otra IA

- **Una sola clase:** `ListaDeNombresApp`, en `app.py`.
- **Estado:** Todo en diccionarios y variables de instancia; sin BD ni archivos de config.
- **UI:** CustomTkinter + ttk.Treeview; tema oscuro; ventana maximizada; paneles: nuevo cliente, tabla, lista de clientes, panel de valores (predefinidos + personalizado + checkbox Detalle).
- **Operaciones:** Agregar/eliminar clientes; agregar valores (con opción detalle); eliminar último valor o valor seleccionado en tabla; total por cliente y total general; selección de cliente desde botones o desde clic en tabla.
- **Formato de números:** Enteros; visualización con `:,` (separador de miles) y prefijo `$`; detalle entre paréntesis en la tabla.

Si otra IA va a modificar la app, conviene tener abierto `app.py` y este contexto para no romper la consistencia entre `clientes`, `detalles`, la tabla y los botones/labels.
