import { SYNC_CIERRE_JORNADA_URL } from '../config';

/**
 * Sincroniza el cierre de jornada con la API externa (Google Apps Script).
 * Se ejecuta en segundo plano; los errores de red se manejan silenciosamente
 * para no interrumpir el flujo local de la app.
 *
 * @param {Object} clientes - Objeto { [nombreCliente]: number[] } con los valores del día
 * @returns {Promise<void>} - Resuelve o rechaza sin propagar errores al caller
 */
export async function syncCerrarJornada(clientes) {
  const bolsas = [];
  const fecha = new Date().toISOString().slice(0, 10);

  Object.keys(clientes || {}).forEach((nombre) => {
    const valores = clientes[nombre] || [];
    if (valores.length === 0) return;
    const cantidadProductos = valores.length;
    const montoTotal = valores.reduce((a, b) => a + b, 0);
    bolsas.push({
      cliente: nombre,
      cantidadProductos,
      montoTotal,
    });
  });

  if (bolsas.length === 0) return;

  const payload = {
    fecha,
    bolsas,
  };

  try {
    const response = await fetch(SYNC_CIERRE_JORNADA_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });
    if (!response.ok) {
      // Silencioso: no lanzamos, solo no hacemos nada
    }
  } catch (_) {
    // Error de red: ignorar silenciosamente para no interrumpir el flujo local
  }
}
