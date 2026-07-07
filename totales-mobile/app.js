/**
 * Gestión de Clientes - Totales (versión web responsiva para Android/tablets/smartphones)
 * Misma funcionalidad que la app de escritorio.
 */

(function () {
  'use strict';

  // Estado (equivalente a la app Python)
  const state = {
    clientes: {},       // { nombre: [valores] }
    detalles: {},       // { nombre: [esDetalle, ...] }
    clienteOrden: [],   // [nombre, ...] orden de aparición: el más reciente primero
    clienteSeleccionado: null,
    valorSeleccionado: null,  // { nombre, indice }
  };

  const MAX_COLUMNAS_VALORES = 100;

  // DOM
  const dom = {
    inputNombre: document.getElementById('input-nombre'),
    inputValorInicial: document.getElementById('input-valor-inicial'),
    btnAgregarCliente: document.getElementById('btn-agregar-cliente'),
    totalGeneral: document.getElementById('total-general'),
    tablaHeadRow: document.getElementById('tabla-head-row'),
    tablaBody: document.getElementById('tabla-body'),
    listaClientes: document.getElementById('lista-clientes'),
    btnEliminarCliente: document.getElementById('btn-eliminar-cliente'),
    checkDetalle: document.getElementById('check-detalle'),
    valoresGrid: document.getElementById('valores-grid'),
    inputValorPersonalizado: document.getElementById('input-valor-personalizado'),
    btnValorPersonalizado: document.getElementById('btn-valor-personalizado'),
    paginaInicio: document.getElementById('pagina-inicio'),
    paginaTabla: document.getElementById('pagina-tabla'),
    btnEliminarValorTabla: document.getElementById('btn-eliminar-valor-tabla'),
    menuInicio: document.getElementById('menu-inicio'),
    menuTabla: document.getElementById('menu-tabla'),
    modalEliminarCliente: document.getElementById('modal-eliminar-cliente'),
    modalEliminarTitulo: document.getElementById('modal-eliminar-titulo'),
    modalEliminarCancelar: document.getElementById('modal-eliminar-cancelar'),
    modalEliminarConfirmar: document.getElementById('modal-eliminar-confirmar'),
    modalEliminarValor: document.getElementById('modal-eliminar-valor'),
    modalEliminarValorCancelar: document.getElementById('modal-eliminar-valor-cancelar'),
    modalEliminarValorConfirmar: document.getElementById('modal-eliminar-valor-confirmar'),
    modalValores: document.getElementById('modal-valores'),
    modalValoresTitulo: document.getElementById('modal-valores-titulo'),
    btnCerrarModalValores: document.getElementById('btn-cerrar-modal-valores'),
    toastMensaje: document.getElementById('toast-mensaje'),
    modalNuevoCliente: document.getElementById('modal-nuevo-cliente'),
    btnAbrirModalNuevoCliente: document.getElementById('btn-abrir-modal-nuevo-cliente'),
    btnCerrarModalNuevoCliente: document.getElementById('btn-cerrar-modal-nuevo-cliente'),
  };

  let toastValorTimeout = null;

  function formatMoney(n) {
    return '$' + Number(n).toLocaleString('es');
  }

  function getTotalGeneral() {
    return Object.values(state.clientes).reduce((acc, vals) => acc + vals.reduce((a, b) => a + b, 0), 0);
  }

  function agregarCliente() {
    const nombre = (dom.inputNombre.value || '').trim();
    const valorStr = (dom.inputValorInicial.value || '').trim();
    if (!nombre || !valorStr) return;

    const valor = parseInt(valorStr, 10);
    if (isNaN(valor)) return;
    if (state.clientes[nombre]) return;

    state.clientes[nombre] = [valor];
    state.detalles[nombre] = [false];
    state.clienteOrden = [nombre].concat(state.clienteOrden.filter(function (n) { return n !== nombre; }));

    renderListaClientes();
    actualizarTabla();
    actualizarTotalGeneral();
    dom.inputNombre.value = '';
    dom.inputValorInicial.value = '';
    cerrarModalNuevoCliente();
  }

  function abrirModalValores() {
    if (!state.clienteSeleccionado) return;
    if (dom.modalValoresTitulo) {
      dom.modalValoresTitulo.textContent = 'Valores — ' + state.clienteSeleccionado;
    }
    if (dom.modalValores) dom.modalValores.removeAttribute('hidden');
  }

  function cerrarModalValores() {
    if (dom.modalValores) dom.modalValores.setAttribute('hidden', '');
  }

  function abrirModalNuevoCliente() {
    if (dom.modalNuevoCliente) dom.modalNuevoCliente.removeAttribute('hidden');
    if (dom.inputNombre) dom.inputNombre.focus();
  }

  function cerrarModalNuevoCliente() {
    if (dom.modalNuevoCliente) dom.modalNuevoCliente.setAttribute('hidden', '');
  }

  function seleccionarCliente(nombre) {
    state.clienteSeleccionado = nombre;
    state.valorSeleccionado = null;
    actualizarBotonEliminarValor();
    renderListaClientes();
    actualizarTabla();
    abrirModalValores();
  }

  function actualizarTotalGeneral() {
    const total = getTotalGeneral();
    dom.totalGeneral.textContent = 'Total General: ' + formatMoney(total);
  }

  function mostrarToastMensaje(texto, tipo) {
    if (!dom.toastMensaje) return;
    if (toastValorTimeout) {
      clearTimeout(toastValorTimeout);
      toastValorTimeout = null;
    }
    dom.toastMensaje.textContent = texto;
    dom.toastMensaje.classList.remove('toast-eliminado');
    if (tipo === 'eliminado') dom.toastMensaje.classList.add('toast-eliminado');
    dom.toastMensaje.classList.add('visible');
    toastValorTimeout = setTimeout(function () {
      dom.toastMensaje.classList.remove('visible');
      toastValorTimeout = null;
    }, 2200);
  }

  function agregarValorACliente(valor) {
    if (!state.clienteSeleccionado || !state.clientes[state.clienteSeleccionado]) return;

    const esDetalle = dom.checkDetalle.checked;
    state.clientes[state.clienteSeleccionado].push(valor);
    if (!state.detalles[state.clienteSeleccionado]) state.detalles[state.clienteSeleccionado] = [];
    state.detalles[state.clienteSeleccionado].push(esDetalle);
    state.clienteOrden = [state.clienteSeleccionado].concat(state.clienteOrden.filter(function (n) { return n !== state.clienteSeleccionado; }));

    dom.checkDetalle.checked = false;
    renderListaClientes();
    actualizarTabla();
    actualizarTotalGeneral();
    mostrarToastMensaje('✓ Valor agregado: ' + formatMoney(valor), 'agregado');
  }

  function agregarValorPersonalizado() {
    const s = (dom.inputValorPersonalizado.value || '').trim();
    if (!s) return;
    const valor = parseInt(s, 10);
    if (isNaN(valor)) return;
    agregarValorACliente(valor);
    dom.inputValorPersonalizado.value = '';
    dom.inputValorPersonalizado.focus();
  }

  function abrirModalEliminarCliente() {
    if (!state.clienteSeleccionado || !state.clientes[state.clienteSeleccionado]) return;
    if (dom.modalEliminarTitulo) {
      dom.modalEliminarTitulo.textContent = '¿Desea eliminar a ' + state.clienteSeleccionado + '?';
    }
    if (dom.modalEliminarCliente) {
      dom.modalEliminarCliente.removeAttribute('hidden');
    }
  }

  function cerrarModalEliminarCliente() {
    if (dom.modalEliminarCliente) {
      dom.modalEliminarCliente.setAttribute('hidden', '');
    }
  }

  function abrirModalEliminarValor() {
    if (!state.valorSeleccionado || !state.clienteSeleccionado) return;
    const nombre = state.valorSeleccionado.nombre;
    const indice = state.valorSeleccionado.indice;
    if (!state.clientes[nombre] || indice < 0 || indice >= state.clientes[nombre].length) return;
    if (dom.modalEliminarValor) dom.modalEliminarValor.removeAttribute('hidden');
  }

  function cerrarModalEliminarValor() {
    if (dom.modalEliminarValor) dom.modalEliminarValor.setAttribute('hidden', '');
  }

  function eliminarCliente() {
    if (!state.clienteSeleccionado || !state.clientes[state.clienteSeleccionado]) return;

    const nombre = state.clienteSeleccionado;
    delete state.clientes[nombre];
    delete state.detalles[nombre];
    state.clienteOrden = state.clienteOrden.filter(function (n) { return n !== nombre; });
    state.clienteSeleccionado = null;
    state.valorSeleccionado = null;
    actualizarBotonEliminarValor();

    renderListaClientes();
    actualizarTabla();
    actualizarTotalGeneral();
    mostrarToastMensaje('✓ Cliente eliminado', 'eliminado');
  }

  function eliminarUltimoValor() {
    if (!state.clienteSeleccionado || !state.clientes[state.clienteSeleccionado]) return;

    const vals = state.clientes[state.clienteSeleccionado];
    vals.pop();
    if (state.detalles[state.clienteSeleccionado]) state.detalles[state.clienteSeleccionado].pop();

    if (vals.length === 0) {
      eliminarCliente();
      return;
    }
    state.valorSeleccionado = null;
    actualizarBotonEliminarValor();
    renderListaClientes();
    actualizarTabla();
    actualizarTotalGeneral();
  }

  function eliminarValorSeleccionado() {
    if (!state.valorSeleccionado || !state.clienteSeleccionado) return;
    const { nombre, indice } = state.valorSeleccionado;
    if (!state.clientes[nombre] || indice < 0 || indice >= state.clientes[nombre].length) return;

    state.clientes[nombre].splice(indice, 1);
    if (state.detalles[nombre]) state.detalles[nombre].splice(indice, 1);

    state.valorSeleccionado = null;
    state.clienteSeleccionado = state.clientes[nombre].length ? nombre : null;
    actualizarBotonEliminarValor();

    if (state.clientes[nombre] && state.clientes[nombre].length === 0) {
      delete state.clientes[nombre];
      delete state.detalles[nombre];
      state.clienteOrden = state.clienteOrden.filter(function (n) { return n !== nombre; });
      state.clienteSeleccionado = null;
    }

    renderListaClientes();
    actualizarTabla();
    actualizarTotalGeneral();
    mostrarToastMensaje('✓ Valor eliminado', 'eliminado');
  }

  function actualizarBotonEliminarValor() {
    if (!dom.btnEliminarValorTabla) return;
    if (state.valorSeleccionado && state.clienteSeleccionado && state.clientes[state.valorSeleccionado.nombre]) {
      const nombre = state.valorSeleccionado.nombre;
      const indice = state.valorSeleccionado.indice;
      const valores = state.clientes[nombre];
      if (indice >= 0 && indice < valores.length) {
        dom.btnEliminarValorTabla.textContent = 'Eliminar ' + formatMoney(valores[indice]) + ' (' + nombre + ')';
        return;
      }
    }
    dom.btnEliminarValorTabla.textContent = 'Eliminar Valor';
  }

  function onTablaClick(e) {
    const cell = e.target.closest('td.celda-valor');
    if (!cell) return;

    const tr = cell.closest('tr');
    const nombre = tr.dataset.nombre;
    const indice = parseInt(cell.dataset.indice, 10);
    if (!nombre || !state.clientes[nombre] || isNaN(indice)) return;

    state.clienteSeleccionado = nombre;
    state.valorSeleccionado = { nombre, indice };

    actualizarBotonEliminarValor();
    document.querySelectorAll('#tabla-body tr').forEach(r => r.classList.remove('selected'));
    tr.classList.add('selected');
    renderListaClientes();
  }

  function getOrdenClientes() {
    var ordenados = state.clienteOrden.filter(function (n) { return state.clientes[n]; });
    var restantes = Object.keys(state.clientes).filter(function (n) { return state.clienteOrden.indexOf(n) === -1; });
    return ordenados.concat(restantes);
  }

  function renderListaClientes() {
    dom.listaClientes.innerHTML = '';
    getOrdenClientes().forEach(function (nombre) {
      const valores = state.clientes[nombre];
      const total = valores.reduce(function (a, b) { return a + b; }, 0);
      const cantidad = valores.length;
      const selected = nombre === state.clienteSeleccionado;

      const wrap = document.createElement('div');
      wrap.className = 'cliente-item';

      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'btn btn-cliente' + (selected ? ' selected' : '');
      btn.textContent = nombre;
      btn.addEventListener('click', function () { seleccionarCliente(nombre); });

      const lblTotal = document.createElement('span');
      lblTotal.className = 'cliente-total';
      lblTotal.textContent = 'Total: ' + formatMoney(total);

      const lblCant = document.createElement('span');
      lblCant.className = 'cliente-cantidad';
      lblCant.textContent = 'Cantidad: ' + cantidad;

      const datosWrap = document.createElement('div');
      datosWrap.className = 'cliente-datos';
      datosWrap.appendChild(lblTotal);
      datosWrap.appendChild(lblCant);

      wrap.appendChild(btn);
      wrap.appendChild(datosWrap);
      dom.listaClientes.appendChild(wrap);
    });
  }

  function actualizarTabla() {
    state.valorSeleccionado = null;
    actualizarBotonEliminarValor();

    const nombres = getOrdenClientes();
    const maxValores = nombres.length
      ? Math.min(MAX_COLUMNAS_VALORES, Math.max(...nombres.map(function (n) { return state.clientes[n].length; }), 1))
      : 1;

    // Headers: Nombre + Valor 1..N + Total
    dom.tablaHeadRow.innerHTML = '';
    const thNombre = document.createElement('th');
    thNombre.className = 'col-nombre';
    thNombre.textContent = 'Nombre';
    dom.tablaHeadRow.appendChild(thNombre);

    for (let i = 0; i < maxValores; i++) {
      const th = document.createElement('th');
      th.textContent = 'Valor ' + (i + 1);
      th.className = 'col-valor';
      dom.tablaHeadRow.appendChild(th);
    }

    const thTotal = document.createElement('th');
    thTotal.className = 'col-total';
    thTotal.textContent = 'Total';
    dom.tablaHeadRow.appendChild(thTotal);

    // Body
    dom.tablaBody.innerHTML = '';
    nombres.forEach(function (nombre) {
      const valores = state.clientes[nombre];
      const detallesCliente = state.detalles[nombre] || valores.map(function () { return false; });
      const total = valores.reduce(function (a, b) { return a + b; }, 0);

      const tr = document.createElement('tr');
      tr.dataset.nombre = nombre;
      if (nombre === state.clienteSeleccionado && state.valorSeleccionado && state.valorSeleccionado.nombre === nombre) {
        tr.classList.add('selected');
      }

      const tdNombre = document.createElement('td');
      tdNombre.className = 'col-nombre';
      tdNombre.textContent = nombre;
      tr.appendChild(tdNombre);

      for (let i = 0; i < maxValores; i++) {
        const td = document.createElement('td');
        td.className = 'celda-valor';
        td.dataset.indice = String(i);
        if (i < valores.length) {
          const esDetalle = detallesCliente[i];
          td.textContent = esDetalle ? '(' + formatMoney(valores[i]) + ')' : formatMoney(valores[i]);
        }
        tr.appendChild(td);
      }

      const tdTotal = document.createElement('td');
      tdTotal.className = 'col-total';
      tdTotal.textContent = formatMoney(total);
      tr.appendChild(tdTotal);

      dom.tablaBody.appendChild(tr);
    });
  }

  function actualizarMenuActivo(esTabla) {
    if (dom.menuInicio) dom.menuInicio.classList.toggle('activo', !esTabla);
    if (dom.menuTabla) dom.menuTabla.classList.toggle('activo', esTabla);
  }

  function irATabla() {
    if (dom.paginaInicio) dom.paginaInicio.classList.remove('activa');
    if (dom.paginaTabla) dom.paginaTabla.classList.add('activa');
    actualizarMenuActivo(true);
    if (window.location.hash !== '#tabla') window.location.hash = 'tabla';
  }

  function irAInicio() {
    if (dom.paginaTabla) dom.paginaTabla.classList.remove('activa');
    if (dom.paginaInicio) dom.paginaInicio.classList.add('activa');
    actualizarMenuActivo(false);
    if (window.location.hash !== '') window.location.hash = '';
  }

  function aplicarPaginaSegunHash() {
    if (window.location.hash === '#tabla') {
      if (dom.paginaInicio) dom.paginaInicio.classList.remove('activa');
      if (dom.paginaTabla) dom.paginaTabla.classList.add('activa');
      actualizarMenuActivo(true);
    } else {
      if (dom.paginaTabla) dom.paginaTabla.classList.remove('activa');
      if (dom.paginaInicio) dom.paginaInicio.classList.add('activa');
      actualizarMenuActivo(false);
    }
  }

  function init() {
    dom.btnAgregarCliente.addEventListener('click', agregarCliente);
    dom.inputNombre.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') agregarCliente();
    });
    dom.inputValorInicial.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') agregarCliente();
    });

    dom.btnEliminarCliente.addEventListener('click', abrirModalEliminarCliente);

    dom.valoresGrid.querySelectorAll('.btn-valor').forEach(function (btn) {
      btn.addEventListener('click', function () {
        const v = parseInt(btn.getAttribute('data-valor'), 10);
        if (!isNaN(v)) agregarValorACliente(v);
      });
    });

    dom.btnValorPersonalizado.addEventListener('click', agregarValorPersonalizado);
    dom.inputValorPersonalizado.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') agregarValorPersonalizado();
    });

    dom.tablaBody.addEventListener('click', function (e) {
      if (e.target.classList.contains('celda-valor')) onTablaClick(e);
    });

    if (dom.btnEliminarValorTabla) dom.btnEliminarValorTabla.addEventListener('click', abrirModalEliminarValor);

    if (dom.modalEliminarValorCancelar) dom.modalEliminarValorCancelar.addEventListener('click', cerrarModalEliminarValor);
    if (dom.modalEliminarValorConfirmar) dom.modalEliminarValorConfirmar.addEventListener('click', function () {
      eliminarValorSeleccionado();
      cerrarModalEliminarValor();
    });
    if (dom.modalEliminarValor) {
      dom.modalEliminarValor.addEventListener('click', function (e) {
        if (e.target === dom.modalEliminarValor) cerrarModalEliminarValor();
      });
    }

    if (dom.menuInicio) dom.menuInicio.addEventListener('click', function (e) {
      e.preventDefault();
      irAInicio();
    });
    if (dom.menuTabla) dom.menuTabla.addEventListener('click', function (e) {
      e.preventDefault();
      irATabla();
    });

    if (dom.modalEliminarCancelar) dom.modalEliminarCancelar.addEventListener('click', cerrarModalEliminarCliente);
    if (dom.modalEliminarConfirmar) dom.modalEliminarConfirmar.addEventListener('click', function () {
      eliminarCliente();
      cerrarModalEliminarCliente();
    });
    if (dom.modalEliminarCliente) {
      dom.modalEliminarCliente.addEventListener('click', function (e) {
        if (e.target === dom.modalEliminarCliente) cerrarModalEliminarCliente();
      });
    }

    if (dom.btnCerrarModalValores) dom.btnCerrarModalValores.addEventListener('click', cerrarModalValores);
    if (dom.modalValores) {
      dom.modalValores.addEventListener('click', function (e) {
        if (e.target === dom.modalValores) cerrarModalValores();
      });
    }

    if (dom.btnAbrirModalNuevoCliente) dom.btnAbrirModalNuevoCliente.addEventListener('click', abrirModalNuevoCliente);
    if (dom.btnCerrarModalNuevoCliente) dom.btnCerrarModalNuevoCliente.addEventListener('click', cerrarModalNuevoCliente);
    if (dom.modalNuevoCliente) {
      dom.modalNuevoCliente.addEventListener('click', function (e) {
        if (e.target === dom.modalNuevoCliente) cerrarModalNuevoCliente();
      });
    }

    window.addEventListener('hashchange', aplicarPaginaSegunHash);
    aplicarPaginaSegunHash();

    actualizarTotalGeneral();
    renderListaClientes();
    actualizarTabla();
  }

  init();
})();
