const HOJA_CIERRES = 'Registros Jugando Toy';
const HOJA_ENVIOS = 'Envios';
const SPREADSHEET_ID = '11JDY9EZ2B2hCRwdZPi9jegEOmVTXleksDQiZ9FfUJVo';

function doPost(e) {
  try {
    if (!e || !e.postData || !e.postData.contents) {
      return respuestaJson({ success: false, error: 'Sin datos' });
    }

    const data = JSON.parse(e.postData.contents);
    const tipo = data.tipo || 'cierre';

    if (tipo === 'envio') {
      return registrarEnvios(data);
    }

    return registrarCierres(data);
  } catch (err) {
    return respuestaJson({
      success: false,
      error: String(err),
    });
  }
}

function registrarCierres(data) {
  const fecha = data.fecha || '';
  const bolsas = data.bolsas || [];

  if (!fecha || bolsas.length === 0) {
    return respuestaJson({ success: false, error: 'Payload vacío' });
  }

  const hoja = obtenerHoja(HOJA_CIERRES, [
    'Fecha',
    'Cliente',
    'Cantidad Productos',
    'Monto Total',
    'Registrado',
  ]);
  const registrado = new Date();

  bolsas.forEach(function (bolsa) {
    hoja.appendRow([
      fecha,
      bolsa.cliente || '',
      bolsa.cantidadProductos || 0,
      bolsa.montoTotal || 0,
      registrado,
    ]);
  });

  return respuestaJson({
    success: true,
    filasAgregadas: bolsas.length,
  });
}

function registrarEnvios(data) {
  const fecha = data.fecha || '';
  const eventos = data.eventos || [];

  if (!fecha || eventos.length === 0) {
    return respuestaJson({ success: false, error: 'Payload vacío' });
  }

  const hoja = obtenerHoja(HOJA_ENVIOS, [
    'Fecha',
    'Estado',
    'Cliente',
    'Jornada',
    'Paquetes',
    'Artículos',
    'Monto',
    'Registrado',
  ]);
  const registrado = new Date();

  eventos.forEach(function (ev) {
    hoja.appendRow([
      fecha,
      ev.estado || '',
      ev.cliente || '',
      ev.jornada || '',
      ev.paquetes || 0,
      ev.articulos || 0,
      ev.monto || 0,
      registrado,
    ]);
  });

  return respuestaJson({
    success: true,
    filasAgregadas: eventos.length,
  });
}

function obtenerHoja(nombre, encabezados) {
  const libro = SpreadsheetApp.openById(SPREADSHEET_ID);
  let hoja = libro.getSheetByName(nombre);

  if (!hoja) {
    hoja = libro.insertSheet(nombre);
    hoja.appendRow(encabezados);
    hoja.setFrozenRows(1);
    hoja.getRange(1, 1, 1, encabezados.length).setFontWeight('bold');
  }

  return hoja;
}

function respuestaJson(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function probarCierre() {
  const evento = {
    postData: {
      contents: JSON.stringify({
        tipo: 'cierre',
        fecha: '2026-07-13',
        bolsas: [
          { cliente: 'Cliente Prueba', cantidadProductos: 2, montoTotal: 3000 },
        ],
      }),
    },
  };

  Logger.log(doPost(evento).getContent());
}

function probarEnvio() {
  const evento = {
    postData: {
      contents: JSON.stringify({
        tipo: 'envio',
        fecha: '2026-07-13',
        eventos: [
          {
            estado: 'Pendiente',
            cliente: 'Cliente Prueba',
            jornada: 'Jornada Test',
            paquetes: 1,
            articulos: 2,
            monto: 3000,
          },
          {
            estado: 'Pagado',
            cliente: 'Cliente Prueba',
            jornada: '',
            paquetes: 0,
            articulos: 0,
            monto: 1500,
          },
          {
            estado: 'Despachado',
            cliente: 'Cliente Prueba',
            jornada: 'Jornada Test',
            paquetes: 1,
            articulos: 2,
            monto: 3000,
          },
        ],
      }),
    },
  };

  Logger.log(doPost(evento).getContent());
}
