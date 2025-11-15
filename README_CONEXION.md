# Guía de Conexión (EcoGrid)

Este documento explica cómo la app se conecta al dispositivo (ESP32) o a una API basada en Google Sheets, qué parámetros usa, qué endpoints espera y cómo diagnosticar problemas de conexión.

## Objetivo
- Permitir lectura de datos de sensores en tiempo real (dashboard) y detalles por sensor (gráficos y último valor).
- Uniformar el contrato de datos: backend entrega JSON en UTC; la app muestra en UTC-5 si corresponde.

## Flujo de Conexión en la App
- `SensorDashboardScreen`: consulta el endpoint agregado (`/sensors`) para mostrar últimos valores.
- `SensorDetailPage`: consulta el endpoint por tipo (`/<tipo>`) o una API de series (`/sensor?type=<tipo>&limit=N`) para graficar.
- Navegación: `SensorDashboardScreen` pasa a `SensorDetailPage` los parámetros `esp32Ip`, `tipo` y `titulo`.

## Configuración Inicial
1. Red WiFi compartida entre teléfono/emulador y el ESP32 o servidor de API.
2. IP o URL del backend (la IP del ESP32 es opcional si usas la Web App):
   - ESP32: por ejemplo `http://192.168.1.50`.
   - Google Sheets (Apps Script): URL del Web App publicada (p. ej. `https://script.google.com/.../exec`).
3. Guardar dirección en la app (opcional para ESP32 si usas Web App):
   - Abrir la pantalla de configuración del dispositivo.
   - Ingresar `esp32Ip` (para ESP32) o `api_base_url` (para Sheets) y guardar.
   - Se persiste en `SharedPreferences` para que el dashboard y el detalle la usen.

## Endpoints Esperados

### A) ESP32 (contrato simple)
- Agregado (dashboard): `GET http://<esp32Ip>/sensors`
  - Respuesta JSON:
    ```json
    {
      "timestamp": "2025-11-02T22:19:24.051Z",
      "temperatura": 26.2,
      "humedad": 66.6,
      "ph": 5.74,
      "tds": 1301
    }
    ```
- Detalle (por tipo): `GET http://<esp32Ip>/<tipo>` donde `<tipo> ∈ {temperatura, humedad, ph, tds}`
  - Respuesta JSON (ejemplo):
    - Temperatura: `{ "temperatura": 26.2 }`
    - Humedad: `{ "humedad": 66.6 }`
    - pH: `{ "ph": 5.74 }`
    - TDS: `{ "tds": 1301 }`

### B) API Google Sheets (series históricas)
- Agregado (dashboard): `GET <api_base_url>/sensors`
  - Formato idéntico al agregado del ESP32.
- Detalle (series): `GET <api_base_url>/sensor?type=<tipo>&limit=<N>`
  - Respuesta JSON:
    ```json
    {
      "type": "temperatura",
      "unit": "C",
      "points": [
        { "timestamp": "2025-11-02T22:19:24.051Z", "value": 26.1 },
        { "timestamp": "2025-11-02T22:19:29.051Z", "value": 26.2 }
      ]
    }
    ```
  - Reglas: `points` ordenados por `timestamp` ascendente; `limit` entre 15–50.

## Variables Clave en la App
- `esp32Ip`: base del dispositivo ESP32 (p. ej. `http://192.168.1.50`).
- `api_base_url`: base del Web App/API (p. ej. `https://.../exec`).
- `tipo`: tipo de sensor (`temperatura`, `humedad`, `ph`, `tds`).
- `valorActual`: valor numérico destacado en detalle.
- `valores`: lista de valores para graficar; se limita a 15 elementos.
- Intervalo de actualización (detalle): 5 segundos (polling).
- Timeout de solicitudes (dashboard): 3 segundos.
- Tiempo: `timestamp` en ISO 8601 UTC (termina con `Z`). La app puede convertir a UTC-5.

## Unidades y Rangos
- Temperatura: `°C` (0–50 típicamente).
- Humedad: `%` (0–100).
- pH: `0–14` (agua 6–8 típico).
- TDS: `ppm` (0–3000 depende de sensor/solución).

## Ejemplos Rápidos
- Último agregado: `{ "timestamp": "2025-11-02T22:19:24.051Z", "temperatura": 26.2, "humedad": 66.6, "ph": 5.74, "tds": 1301 }`
- Detalle por tipo (ESP32): `{ "ph": 5.74 }`
- Series (Sheets): `{ "type": "tds", "unit": "ppm", "points": [ {"timestamp": "...", "value": 1280}, {"timestamp": "...", "value": 1301} ] }`

## Diagnóstico de Conexión
- Verifica la IP/URL en un navegador desde el mismo dispositivo/red.
- Prueba `http://<esp32Ip>/sensors` o `<api_base_url>/sensors` y confirma JSON válido.
- Revisa CORS (Apps Script): publicar Web App con acceso "Cualquiera" y responder `Content-Type: application/json`.
- Comprueba que el teléfono/emulador y el ESP32 están en la misma subred.
- Si no hay datos, la app muestra “Sin datos aún...”; revisa logs (`debugPrint`).

## Manejo de Tiempo
- Backend: guardar/enviar en UTC (`...Z`).
- App: convertir a UTC-5 para mostrar (Perú), por ejemplo:
  - `DateTime.parse(ts).toUtc().subtract(const Duration(hours: 5))`.
  - Alternativa robusta: librería `timezone` con `America/Lima`.

## Buenas Prácticas
- Normaliza números con punto decimal (no comas, sin separadores de miles).
- Limita el tamaño de series (`limit`) para rendimiento.
- Cachea `/sensors` por 2–5 segundos del lado backend si es posible.
- Documenta claramente unidades y rangos por sensor.

## Seguridad (opcional)
- Si el Web App es público, evalúa API keys simples y revisa cuotas de Apps Script.
- Evita exponer IPs públicas del ESP32; usa una API intermedia si sales de red local.

## Próximos Pasos
- Decide si el detalle consumirá `/<tipo>` (ESP32) o `sensor?type=<tipo>` (Sheets).
- Si usas Sheets, guarda `api_base_url` y ajusta `SensorDetailPage` para usar series.
- Prueba la conectividad desde el dashboard y valida un gráfico en detalle.