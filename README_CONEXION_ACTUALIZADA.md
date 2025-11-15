# Conexión Actualizada: Web App (Sheets) y ESP32

Este documento explica cómo la app se conecta hoy a las fuentes de datos, las rutas utilizadas, los contratos esperados, y cómo configurar el origen para habilitar el modo automático con Google Sheets (Web App) o el fallback al ESP32.

## Objetivo
- Priorizar la Web App (Google Apps Script) cuando esté configurada.
- Mantener fallback al ESP32 cuando no exista configuración de la Web App.
- Alinear rutas y contratos entre `Main Menu` y `Sensor Detail`.

## Orígenes de datos y prioridad
- Web App (Sheets): `api_base_url` (SharedPreferences) o `AppConfig.DEFAULT_API_BASE_URL`.
- ESP32: IP del dispositivo (`esp32_ip`) para consumo directo.
- Prioridad de conexión:
  1) Si existe `api_base_url` guardado o `DEFAULT_API_BASE_URL` en código, se usa Web App.
  2) Si no hay Web App configurada, se usa ESP32.

## Configuración
- Código: definir `DEFAULT_API_BASE_URL` en `lib/constants/app_config.dart` (clase `AppConfig`).
  - Debe ser la URL completa del Web App, normalmente termina en `/exec`.
  - Ejemplo: `https://script.google.com/macros/s/XXXXXXXXXXXX/exec`.
- Preferencias (opcional): guardar `api_base_url` en SharedPreferences para que la app use esa URL sin necesidad de recompilar.
  - Si existe `api_base_url` guardado, tiene prioridad sobre `DEFAULT_API_BASE_URL`.

## Bloques y rutas

### Main Menu (Resumen de sensores)
- Modo Web App (Sheets):
  - `GET <api_base_url>?endpoint=lastReading`
  - Respuesta esperada (JSON objeto):
    ```json
    {
      "temperatura": 24.8,
      "humedad": 51.2,
      "ph": 6.7,
      "tds": 520,
      "timestamp": "2025-11-10T14:25:00Z"
    }
    ```
- Fallback ESP32:
  - `GET http://<esp32_ip>/sensors`
  - Respuesta esperada (JSON objeto, mismas claves):
    ```json
    {
      "temperatura": 24.8,
      "humedad": 51.2,
      "ph": 6.7,
      "tds": 520,
      "timestamp": "2025-11-10T14:25:00Z"
    }
    ```

### Sensor Detail (Histórico por tipo)
- Modo Web App (Sheets):
  - `GET <api_base_url>?endpoint=history&type=<tipo>&limit=15`
  - `<tipo>`: `temperatura`, `humedad`, `ph`, `tds`.
  - Respuesta esperada (JSON array):
    ```json
    [
      { "value": 24.8, "timestamp": "2025-11-10T14:20:00Z" },
      { "value": 24.9, "timestamp": "2025-11-10T14:25:00Z" }
    ]
    ```
- Fallback ESP32:
  - `GET http://<esp32_ip>/<tipo>` (una por cada tipo)
  - Respuesta esperada (JSON objeto o arreglo, según firmware):
    ```json
    {
      "value": 24.8,
      "timestamp": "2025-11-10T14:25:00Z"
    }
    ```

## Flujo de decisión en tiempo de ejecución
- Main Menu:
  - Detecta `api_base_url` (SharedPreferences). Si está vacío, usa `AppConfig.DEFAULT_API_BASE_URL`.
  - Si hay URL efectiva, consume `endpoint=lastReading`. Si no, consume `http://<esp32_ip>/sensors`.
- Sensor Detail:
  - Misma detección de `api_base_url`/`DEFAULT_API_BASE_URL`.
  - Si hay URL efectiva, consume `endpoint=history`. Si no, consume `http://<esp32_ip>/<tipo>`.

## Cambio: eliminación del bloqueo inicial en Sensor Dashboard
- Se retiró el bloqueo que exigía configurar la IP del ESP32 para abrir los detalles.
- El Dashboard navega siempre al detalle del sensor; si no hay `esp32_ip`, se usa la Web App por defecto.
- `SensorDetailPage` acepta `esp32Ip` opcional y prioriza la API; solo usa ESP32 si hay IP configurada.

## Ubicaciones en código
- `lib/constants/app_config.dart`: define `AppConfig.DEFAULT_API_BASE_URL` (fallback para Web App).
- `lib/screens/main_menu_screen.dart`: lógica dual-mode para `lastReading` (Sheets) o `/sensors` (ESP32).
- `lib/screens/sensor_detail_page.dart`: lógica dual-mode para `history` (Sheets) o `/<tipo>` (ESP32).

## Pruebas rápidas
1) Establece `DEFAULT_API_BASE_URL` en `lib/constants/app_config.dart` con tu URL `/exec`.
2) Ejecuta la app:
   - Web (Chrome): `flutter run -d chrome`
   - Windows: `flutter run -d windows`
3) Verifica en el Main Menu que se muestren valores y timestamp.
4) Entra a `Sensor Detail` y confirma que el historial se renderiza.
5) Quita `DEFAULT_API_BASE_URL` y cualquier `api_base_url` guardado para validar el fallback al ESP32.

## Errores comunes y soluciones
- URL incorrecta (no termina en `/exec`): corrige `DEFAULT_API_BASE_URL` o `api_base_url`.
- CORS en web: asegúrate que el Web App esté desplegado como "Acceso a cualquiera".
- `api_base_url` vacío y `DEFAULT_API_BASE_URL` sin definir: la app usará ESP32.
- IP de ESP32 no configurada o fuera de red: ajusta `esp32_ip` en la pantalla de configuración y verifica conectividad.

## Recomendaciones
- Usa `api_base_url` en preferencias para facilitar cambios sin recompilar.
- Mantén consistentes las claves del JSON: `temperatura`, `humedad`, `ph`, `tds`, `timestamp`.
- En el Web App, implementa `endpoint=lastReading` y `endpoint=history` con estos contratos.

---
Si quieres, puedo añadir un campo en la pantalla de configuración para editar `api_base_url` desde la UI y activar automáticamente el modo Sheets.