import customtkinter as ctk
import tkinter as tk
from tkinter import ttk

# Configurar tema y apariencia
ctk.set_appearance_mode("dark")  # "dark" o "light"
ctk.set_default_color_theme("blue")  # "blue", "green", "dark-blue"


class ListaDeNombresApp:
    """Aplicación moderna para gestionar clientes y sus valores."""

    def __init__(self, root: ctk.CTk) -> None:
        self.root = root
        self.root.title("Gestión de Clientes - Totales")
        self.root.geometry("1000x700")
        self.root.minsize(700, 500)
        self.root.after(0, self._maximizar_ventana)

        self.nombre_var = ctk.StringVar()
        self.valor_var = ctk.StringVar()
        self.valor_personalizado_var = ctk.StringVar()
        self.detalle_var = ctk.BooleanVar()  # Variable para el checkbox de detalle
        self.clientes = {}  # {nombre: [valores]}
        self.detalles = {}  # {nombre: [es_detalle, ...]} - indica si cada valor es detalle
        self.cliente_seleccionado = None  # Cliente actualmente seleccionado
        self.valor_seleccionado = None  # Índice del valor seleccionado en la tabla
        self.botones_clientes = {}  # {nombre: boton}
        self.labels_totales = {}  # {nombre: label_total}
        self.labels_cantidad = {}  # {nombre: label_cantidad}

        self._construir_ui()

    def _construir_ui(self) -> None:
        # Contenedor principal
        contenedor = ctk.CTkScrollableFrame(self.root, corner_radius=0)
        contenedor.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        self.contenedor = contenedor

        # Frame para campos de entrada con estilo moderno
        entrada_frame = ctk.CTkFrame(contenedor, corner_radius=10)
        entrada_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 20))
        self.entrada_frame = entrada_frame

        # Header de la sección con título y total general
        header_seccion = ctk.CTkFrame(entrada_frame, fg_color="transparent")
        header_seccion.pack(fill=tk.X, padx=20, pady=(15, 10))
        
        titulo_seccion = ctk.CTkLabel(
            header_seccion,
            text="Nuevo Cliente",
            font=ctk.CTkFont(size=20, weight="bold")
        )
        titulo_seccion.pack(side=tk.LEFT)

        # Indicador del total general de todos los clientes
        self.label_total_general = ctk.CTkLabel(
            header_seccion,
            text="Total General: $0",
            font=ctk.CTkFont(size=16, weight="bold"),
            fg_color="#2196F3",
            text_color="white",
            corner_radius=5,
            padx=20,
            pady=8
        )
        self.label_total_general.pack(side=tk.RIGHT)

        # Frame interno para campos (todos en una fila)
        campos_frame = ctk.CTkFrame(entrada_frame, fg_color="transparent")
        campos_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=(0, 15))
        self.campos_frame = campos_frame

        # Campo nombre
        titulo_nombre = ctk.CTkLabel(
            campos_frame,
            text="Nombre del Cliente:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        titulo_nombre.grid(row=0, column=0, sticky="w", padx=(0, 10))

        entrada = ctk.CTkEntry(
            campos_frame,
            textvariable=self.nombre_var,
            placeholder_text="Ingresa el nombre...",
            height=40,
            width=0,
            font=ctk.CTkFont(size=14)
        )
        entrada.grid(row=0, column=1, sticky="ew", padx=(0, 15))
        entrada.bind("<Return>", lambda e: self._agregar_cliente())

        # Campo valor
        titulo_valor = ctk.CTkLabel(
            campos_frame,
            text="Valor Inicial:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        titulo_valor.grid(row=0, column=2, sticky="w", padx=(0, 10))

        entrada_valor = ctk.CTkEntry(
            campos_frame,
            textvariable=self.valor_var,
            placeholder_text="Ingresa el valor inicial...",
            height=40,
            width=0,
            font=ctk.CTkFont(size=14)
        )
        entrada_valor.grid(row=0, column=3, sticky="ew", padx=(0, 15))
        entrada_valor.bind("<Return>", lambda e: self._agregar_cliente())

        # Botón agregar con estilo moderno
        boton_agregar = ctk.CTkButton(
            campos_frame,
            text="+ Agregar Cliente",
            command=self._agregar_cliente,
            height=40,
            font=ctk.CTkFont(size=14, weight="bold"),
            fg_color="#2FA572",
            hover_color="#228B5A"
        )
        boton_agregar.grid(row=0, column=4, sticky="ew")

        # Sección de tabla con estilo moderno
        tabla_container = ctk.CTkFrame(contenedor, corner_radius=10)
        tabla_container.pack(fill=tk.BOTH, expand=True, pady=(0, 20))
        self.tabla_container = tabla_container

        # Header de la tabla con título e indicador
        tabla_header = ctk.CTkFrame(tabla_container, fg_color="transparent")
        tabla_header.pack(fill=tk.X, padx=15, pady=(15, 10))
        
        tabla_titulo = ctk.CTkLabel(
            tabla_header,
            text="Tabla de Clientes",
            font=ctk.CTkFont(size=18, weight="bold")
        )
        tabla_titulo.pack(side=tk.LEFT)

        # Indicador visual del valor seleccionado
        self.indicador_valor_seleccionado = ctk.CTkLabel(
            tabla_header,
            text="",
            font=ctk.CTkFont(size=13, weight="bold"),
            fg_color="transparent",
            text_color="white",
            corner_radius=5,
            padx=15,
            pady=5
        )
        self.indicador_valor_seleccionado.pack(side=tk.RIGHT)

        # Frame para tabla con scrollbar
        tabla_frame = ctk.CTkFrame(tabla_container, fg_color="transparent")
        tabla_frame.pack(fill=tk.BOTH, expand=True, padx=15, pady=(0, 15))
        self.tabla_frame = tabla_frame

        # Crear Treeview (tabla) con columnas dinámicas (aumentado a 100 columnas para valores)
        columnas = ["Nombre"] + [f"Valor{i+1}" for i in range(100)] + ["Total"]
        self.tabla = ttk.Treeview(tabla_frame, columns=columnas, show="headings", height=8)
        
        # Estilo moderno para la tabla
        style = ttk.Style()
        style.theme_use("clam")
        style.configure("Treeview",
                       background="#2b2b2b",
                       foreground="white",
                       fieldbackground="#2b2b2b",
                       rowheight=35,
                       font=("Arial", 14))
        style.configure("Treeview.Heading",
                       background="#1f538d",
                       foreground="white",
                       relief="flat",
                       font=("Arial", 16, "bold"))
        style.map("Treeview",
                 background=[("selected", "#4CAF50")],
                 foreground=[("selected", "white")])

        # Configurar encabezados
        self.tabla.heading("Nombre", text="Nombre")
        self.tabla.column("Nombre", width=200)
        for i in range(100):
            self.tabla.heading(f"Valor{i+1}", text=f"Valor {i+1}")
            self.tabla.column(f"Valor{i+1}", width=140)
        self.tabla.heading("Total", text="Total")
        self.tabla.column("Total", width=160)

        # Scrollbar para tabla
        scrollbar_tabla = ttk.Scrollbar(tabla_frame, orient="vertical", command=self.tabla.yview)
        scrollbar_tabla_h = ttk.Scrollbar(tabla_frame, orient="horizontal", command=self.tabla.xview)
        self.tabla.configure(yscrollcommand=scrollbar_tabla.set, xscrollcommand=scrollbar_tabla_h.set)

        # Configurar evento de clic en la tabla
        self.tabla.bind("<Button-1>", self._on_tabla_click)

        self.tabla.grid(row=0, column=0, sticky="nsew")
        scrollbar_tabla.grid(row=0, column=1, sticky="ns")
        scrollbar_tabla_h.grid(row=1, column=0, sticky="ew")
        tabla_frame.grid_columnconfigure(0, weight=1)
        tabla_frame.grid_rowconfigure(0, weight=1)

        # Frame para botones dividido en dos mitades
        frame_botones_principal = ctk.CTkFrame(contenedor, fg_color="transparent")
        frame_botones_principal.pack(fill=tk.BOTH, expand=True)
        self.frame_botones_principal = frame_botones_principal
        frame_botones_principal.grid_columnconfigure(0, weight=1, uniform="botones")
        frame_botones_principal.grid_columnconfigure(1, weight=1, uniform="botones")

        # Panel izquierdo para botones de clientes
        panel_botones_clientes = ctk.CTkFrame(frame_botones_principal, corner_radius=10)
        panel_botones_clientes.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
        panel_botones_clientes.grid_rowconfigure(1, weight=1)
        panel_botones_clientes.grid_columnconfigure(0, weight=1)
        self.panel_botones_clientes = panel_botones_clientes

        # Header del panel de clientes
        header_clientes = ctk.CTkFrame(panel_botones_clientes, fg_color="transparent")
        header_clientes.grid(row=0, column=0, columnspan=2, sticky="ew", padx=15, pady=(15, 10))
        header_clientes.grid_columnconfigure(0, weight=1)

        botones_titulo = ctk.CTkLabel(
            header_clientes,
            text="Clientes",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        botones_titulo.grid(row=0, column=0, sticky="w")

        # Botón para eliminar cliente
        boton_eliminar_cliente = ctk.CTkButton(
            header_clientes,
            text="Eliminar Cliente",
            command=self._eliminar_cliente,
            width=120,
            height=30,
            font=ctk.CTkFont(size=12),
            fg_color="#D32F2F",
            hover_color="#B71C1C"
        )
        boton_eliminar_cliente.grid(row=0, column=1, sticky="e", padx=(10, 0))

        # Frame scrollable para botones de clientes
        self.scrollable_frame_clientes = ctk.CTkScrollableFrame(panel_botones_clientes, height=300)
        self.scrollable_frame_clientes.grid(row=1, column=0, columnspan=2, sticky="nsew", padx=15, pady=(0, 15))

        # Sección de valores
        panel_botones_valores = ctk.CTkFrame(frame_botones_principal, corner_radius=10)
        panel_botones_valores.grid(row=0, column=1, sticky="nsew", padx=(10, 0))
        panel_botones_valores.grid_rowconfigure(1, weight=1)
        panel_botones_valores.grid_columnconfigure(0, weight=1)
        self.panel_botones_valores = panel_botones_valores

        # Header del panel de valores
        header_valores = ctk.CTkFrame(panel_botones_valores, fg_color="transparent")
        header_valores.grid(row=0, column=0, columnspan=2, sticky="ew", padx=15, pady=(15, 10))
        header_valores.grid_columnconfigure(2, weight=1)

        # Label "Detalle" y checkbox
        detalle_label = ctk.CTkLabel(
            header_valores,
            text="Detalle:",
            font=ctk.CTkFont(size=14, weight="bold")
        )
        detalle_label.grid(row=0, column=0, sticky="w", padx=(0, 5))

        detalle_checkbox = ctk.CTkCheckBox(
            header_valores,
            text="",
            variable=self.detalle_var,
            width=20,
            height=20
        )
        detalle_checkbox.grid(row=0, column=1, sticky="w", padx=(0, 15))

        valores_titulo = ctk.CTkLabel(
            header_valores,
            text="Valores",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        valores_titulo.grid(row=0, column=2, sticky="w")

        # Frame para botones de eliminación
        frame_botones_eliminar = ctk.CTkFrame(header_valores, fg_color="transparent")
        frame_botones_eliminar.grid(row=0, column=3, sticky="e", padx=(10, 0))

        # Botón para eliminar último valor
        boton_eliminar_ultimo = ctk.CTkButton(
            frame_botones_eliminar,
            text="Eliminar Ultimo",
            command=self._eliminar_ultimo_valor,
            width=90,
            height=30,
            font=ctk.CTkFont(size=10),
            fg_color="#FF6B35",
            hover_color="#E55A2B"
        )
        boton_eliminar_ultimo.grid(row=0, column=0, padx=(0, 5))

        # Botón para eliminar valor seleccionado
        boton_eliminar_valor = ctk.CTkButton(
            frame_botones_eliminar,
            text="Eliminar Valor",
            command=self._eliminar_valor_seleccionado,
            width=90,
            height=30,
            font=ctk.CTkFont(size=10),
            fg_color="#FF6B35",
            hover_color="#E55A2B"
        )
        boton_eliminar_valor.grid(row=0, column=1)

        # Frame scrollable para botones de valores
        self.scrollable_frame_valores = ctk.CTkScrollableFrame(panel_botones_valores, height=300)
        self.scrollable_frame_valores.grid(row=1, column=0, columnspan=2, sticky="nsew", padx=15, pady=(0, 15))
        
        # Configurar columnas para grid
        self.scrollable_frame_valores.grid_columnconfigure(0, weight=1)
        self.scrollable_frame_valores.grid_columnconfigure(1, weight=1)

        # Botones de valores predefinidos (incluyendo 0)
        valores = [0, 500, 1000, 1500, 2000, 2500, 3000, 3500]
        num_filas = (len(valores) + 1) // 2  # Número de filas necesarias
        
        for idx, valor in enumerate(valores):
            boton_valor = ctk.CTkButton(
                self.scrollable_frame_valores,
                text=str(valor),
                command=lambda v=valor: self._agregar_valor_a_cliente(v),
                height=35,
                width=120,
                font=ctk.CTkFont(size=13, weight="bold")
            )
            # Distribuir en 2 columnas
            col = idx % 2
            row = idx // 2
            boton_valor.grid(row=row, column=col, padx=5, pady=5, sticky="ew")

        # Frame para valor personalizado (ocupa las 2 columnas)
        frame_valor_personalizado = ctk.CTkFrame(self.scrollable_frame_valores, fg_color="transparent")
        frame_valor_personalizado.grid(row=num_filas, column=0, columnspan=2, sticky="ew", pady=(10, 5))
        frame_valor_personalizado.grid_columnconfigure(0, weight=1)
        
        entrada_valor_personalizado = ctk.CTkEntry(
            frame_valor_personalizado,
            textvariable=self.valor_personalizado_var,
            placeholder_text="Valor personalizado...",
            height=35,
            font=ctk.CTkFont(size=13)
        )
        entrada_valor_personalizado.grid(row=0, column=0, sticky="ew", padx=(0, 5))
        entrada_valor_personalizado.bind("<Return>", lambda e: self._agregar_valor_personalizado())

        boton_agregar_personalizado = ctk.CTkButton(
            frame_valor_personalizado,
            text="+",
            command=self._agregar_valor_personalizado,
            width=50,
            height=35,
            font=ctk.CTkFont(size=16),
            fg_color="#2FA572",
            hover_color="#228B5A"
        )
        boton_agregar_personalizado.grid(row=0, column=1, sticky="w")

        self._configurar_responsividad()

    def _maximizar_ventana(self) -> None:
        """Intenta maximizar la ventana en cualquier sistema operativo."""
        try:
            self.root.state("zoomed")
        except tk.TclError:
            # Algunos sistemas (ej. macOS) no soportan 'zoomed'
            try:
                self.root.attributes("-zoomed", True)
            except tk.TclError:
                # Último recurso: ajustar a la resolución disponible
                ancho = self.root.winfo_screenwidth()
                alto = self.root.winfo_screenheight()
                self.root.geometry(f"{ancho}x{alto}")

    def _configurar_responsividad(self) -> None:
        """Configura pesos de columnas y filas para permitir un layout fluido."""
        if hasattr(self, "campos_frame"):
            self.campos_frame.grid_columnconfigure(0, weight=0)
            self.campos_frame.grid_columnconfigure(1, weight=1)
            self.campos_frame.grid_columnconfigure(2, weight=0)
            self.campos_frame.grid_columnconfigure(3, weight=1)
            self.campos_frame.grid_columnconfigure(4, weight=0)

        if hasattr(self, "tabla_frame"):
            self.tabla_frame.grid_columnconfigure(0, weight=1)
            self.tabla_frame.grid_rowconfigure(0, weight=1)

        if hasattr(self, "panel_botones_clientes"):
            self.panel_botones_clientes.grid_rowconfigure(1, weight=1)

        if hasattr(self, "panel_botones_valores"):
            self.panel_botones_valores.grid_rowconfigure(1, weight=1)

        if hasattr(self, "frame_botones_principal"):
            self.frame_botones_principal.grid_rowconfigure(0, weight=1)

    def _agregar_cliente(self) -> None:
        """Agrega un nuevo cliente con su valor inicial."""
        nombre = self.nombre_var.get().strip()
        valor_str = self.valor_var.get().strip()
        
        if not nombre or not valor_str:
            return

        try:
            valor = int(valor_str)
        except ValueError:
            return

        if nombre in self.clientes:
            return

        self.clientes[nombre] = [valor]
        self.detalles[nombre] = [False]  # El valor inicial no es detalle

        # Crear frame para botón y total
        frame_boton = ctk.CTkFrame(self.scrollable_frame_clientes, fg_color="transparent")
        frame_boton.pack(fill=tk.X, pady=5)

        # Crear botón de cliente
        boton_nombre = ctk.CTkButton(
            frame_boton,
            text=nombre,
            command=lambda n=nombre: self._seleccionar_cliente(n),
            width=150,
            height=35,
            font=ctk.CTkFont(size=13),
            fg_color="#1f538d",
            hover_color="#2a6ba0"
        )
        boton_nombre.pack(side=tk.LEFT, padx=(0, 10))

        # Crear label para mostrar el total
        total = sum(self.clientes[nombre])
        cantidad = len(self.clientes[nombre])
        label_total = ctk.CTkLabel(
            frame_boton,
            text=f"Total: ${total:,}",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color="#4CAF50"
        )
        label_total.pack(side=tk.LEFT, padx=(0, 10))

        # Crear label para mostrar la cantidad de productos
        label_cantidad = ctk.CTkLabel(
            frame_boton,
            text=f"Cantidad: {cantidad}",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color="#FF9800"
        )
        label_cantidad.pack(side=tk.LEFT)

        self.botones_clientes[nombre] = boton_nombre
        self.labels_totales[nombre] = label_total
        self.labels_cantidad[nombre] = label_cantidad

        self._actualizar_tabla()
        self._actualizar_total_general()

        # Limpiar campos
        self.nombre_var.set("")
        self.valor_var.set("")

    def _seleccionar_cliente(self, nombre: str) -> None:
        """Selecciona un cliente para añadirle valores."""
        self.cliente_seleccionado = nombre
        self._actualizar_botones_clientes()

    def _actualizar_botones_clientes(self) -> None:
        """Actualiza el texto de todos los botones de clientes, sus totales y cantidades."""
        for nombre, boton in self.botones_clientes.items():
            if nombre in self.clientes:
                total = sum(self.clientes[nombre])
                cantidad = len(self.clientes[nombre])
                if nombre == self.cliente_seleccionado:
                    boton.configure(
                        text=f"✓ {nombre}",
                        fg_color="#4CAF50",
                        hover_color="#45a049"
                    )
                else:
                    boton.configure(
                        text=nombre,
                        fg_color="#1f538d",
                        hover_color="#2a6ba0"
                    )
                if nombre in self.labels_totales:
                    self.labels_totales[nombre].configure(text=f"Total: ${total:,}")
                if nombre in self.labels_cantidad:
                    self.labels_cantidad[nombre].configure(text=f"Cantidad: {cantidad}")
        
        self._actualizar_total_general()

    def _actualizar_total_general(self) -> None:
        """Calcula y actualiza el total general de todos los clientes."""
        total_general = sum(sum(valores) for valores in self.clientes.values())
        self.label_total_general.configure(text=f"Total General: ${total_general:,}")

    def _agregar_valor_a_cliente(self, valor: int) -> None:
        """Añade un valor al cliente seleccionado."""
        if not self.cliente_seleccionado:
            return

        if self.cliente_seleccionado in self.clientes:
            # Verificar si el checkbox de detalle está marcado
            es_detalle = self.detalle_var.get()
            
            self.clientes[self.cliente_seleccionado].append(valor)
            
            # Almacenar si este valor es detalle
            if self.cliente_seleccionado not in self.detalles:
                self.detalles[self.cliente_seleccionado] = []
            self.detalles[self.cliente_seleccionado].append(es_detalle)
            
            # Desmarcar el checkbox después de agregar el valor
            self.detalle_var.set(False)
            
            self._actualizar_botones_clientes()
            self._actualizar_tabla()
            self._actualizar_total_general()

    def _agregar_valor_personalizado(self) -> None:
        """Añade un valor personalizado al cliente seleccionado."""
        valor_str = self.valor_personalizado_var.get().strip()
        if not valor_str:
            return

        try:
            valor = int(valor_str)
            self._agregar_valor_a_cliente(valor)
            self.valor_personalizado_var.set("")
        except ValueError:
            return

    def _eliminar_cliente(self) -> None:
        """Elimina el cliente seleccionado."""
        if not self.cliente_seleccionado:
            return

        nombre = self.cliente_seleccionado
        
        if nombre in self.clientes:
            del self.clientes[nombre]
            
            if nombre in self.detalles:
                del self.detalles[nombre]
            
            if nombre in self.botones_clientes:
                frame_boton = self.botones_clientes[nombre].master
                frame_boton.destroy()
                del self.botones_clientes[nombre]
            
            if nombre in self.labels_totales:
                del self.labels_totales[nombre]
            
            if nombre in self.labels_cantidad:
                del self.labels_cantidad[nombre]
            
            self.cliente_seleccionado = None
            self._actualizar_tabla()
            self._actualizar_total_general()

    def _eliminar_ultimo_valor(self) -> None:
        """Elimina el último valor del cliente seleccionado."""
        if not self.cliente_seleccionado:
            return

        if self.cliente_seleccionado in self.clientes:
            valores = self.clientes[self.cliente_seleccionado]
            if len(valores) > 0:
                valores.pop()
                # Eliminar también el detalle correspondiente
                if self.cliente_seleccionado in self.detalles:
                    detalles_list = self.detalles[self.cliente_seleccionado]
                    if len(detalles_list) > 0:
                        detalles_list.pop()
                if len(valores) == 0:
                    self._eliminar_cliente()
                else:
                    self._actualizar_botones_clientes()
                    self._actualizar_tabla()

    def _on_tabla_click(self, event) -> None:
        """Maneja el clic en la tabla para seleccionar un valor."""
        region = self.tabla.identify_region(event.x, event.y)
        if region == "cell":
            item = self.tabla.identify_row(event.y)
            column = self.tabla.identify_column(event.x)
            
            if item and column:
                col_index = int(column.replace("#", ""))
                valores_fila = self.tabla.item(item, "values")
                if not valores_fila or len(valores_fila) == 0:
                    self.valor_seleccionado = None
                    return
                
                nombre_fila = valores_fila[0] if valores_fila else ""
                
                # Si se hace clic en una celda de valor, automáticamente seleccionar ese cliente
                if 2 <= col_index <= 101:  # Es una columna de valor (hasta 100 valores)
                    if nombre_fila and nombre_fila in self.clientes:
                        # Seleccionar automáticamente el cliente si no está seleccionado
                        if self.cliente_seleccionado != nombre_fila:
                            self.cliente_seleccionado = nombre_fila
                            self._actualizar_botones_clientes()
                        
                        # El índice del valor en la lista es col_index - 2
                        indice_valor = col_index - 2
                        
                        # Verificar que el cliente tiene valores y que el índice es válido
                        valores_cliente = self.clientes[nombre_fila]
                        if 0 <= indice_valor < len(valores_cliente):
                            # Verificar que la celda tiene contenido
                            if len(valores_fila) > col_index - 1:
                                valor_str = valores_fila[col_index - 1]
                                if valor_str and valor_str.strip() and valor_str != "":
                                    self.valor_seleccionado = indice_valor
                                    self.tabla.selection_set(item)
                                    
                                    # Actualizar indicador visual
                                    valor_numero = valores_cliente[indice_valor]
                                    self.indicador_valor_seleccionado.configure(
                                        text=f"Valor seleccionado: ${valor_numero:,} (Cliente: {nombre_fila})",
                                        fg_color="#4CAF50"
                                    )
                                    return
                    
                    self.valor_seleccionado = None
                    self.indicador_valor_seleccionado.configure(text="", fg_color="transparent")
                else:
                    self.valor_seleccionado = None
                    self.indicador_valor_seleccionado.configure(text="", fg_color="transparent")

    def _eliminar_valor_seleccionado(self) -> None:
        """Elimina el valor seleccionado en la tabla del cliente seleccionado."""
        if self.valor_seleccionado is None:
            return
        
        if not self.cliente_seleccionado:
            return

        if self.cliente_seleccionado in self.clientes:
            valores = self.clientes[self.cliente_seleccionado]
            # Verificar que el índice es válido
            if 0 <= self.valor_seleccionado < len(valores):
                # Eliminar el valor en el índice seleccionado
                valores.pop(self.valor_seleccionado)
                
                # Eliminar también el detalle correspondiente
                if self.cliente_seleccionado in self.detalles:
                    detalles_list = self.detalles[self.cliente_seleccionado]
                    if 0 <= self.valor_seleccionado < len(detalles_list):
                        detalles_list.pop(self.valor_seleccionado)
                
                self.valor_seleccionado = None
                
                # Limpiar indicador visual
                self.indicador_valor_seleccionado.configure(text="", fg_color="transparent")
                
                # Si no quedan valores, eliminar el cliente
                if len(valores) == 0:
                    self._eliminar_cliente()
                else:
                    self._actualizar_botones_clientes()
                    self._actualizar_tabla()

    def _actualizar_tabla(self) -> None:
        """Actualiza la tabla con todos los clientes y sus valores."""
        self.valor_seleccionado = None
        # Limpiar indicador visual
        self.indicador_valor_seleccionado.configure(text="", fg_color="transparent")
        for item in self.tabla.get_children():
            self.tabla.delete(item)

        max_valores = max(len(valores) for valores in self.clientes.values()) if self.clientes else 0

        for nombre, valores in self.clientes.items():
            total = sum(valores)
            fila = [nombre]
            # Obtener la lista de detalles para este cliente
            detalles_cliente = self.detalles.get(nombre, [False] * len(valores))
            
            # Mostrar todos los valores (hasta 100)
            for i in range(100):
                if i < len(valores):
                    # Si es detalle, mostrar entre paréntesis
                    if i < len(detalles_cliente) and detalles_cliente[i]:
                        fila.append(f"(${valores[i]:,})")
                    else:
                        fila.append(f"${valores[i]:,}")
                else:
                    fila.append("")
            fila.append(f"${total:,}")
            
            self.tabla.insert("", tk.END, values=fila)


def main() -> None:
    root = ctk.CTk()
    ListaDeNombresApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
