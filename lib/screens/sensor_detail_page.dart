import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SensorDetailPage extends StatefulWidget {
  final String? esp32Ip;
  final String tipo;
  final String titulo;

  const SensorDetailPage({
    super.key,
    this.esp32Ip,
    required this.tipo,
    required this.titulo,
  });

  @override
  State<SensorDetailPage> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  // --- VARIABLES DE ESTADO ---
  List<double> valores = []; // Para el gráfico
  Timer? timer;
  String? apiBaseUrl;

  // Nuevas variables de estado
  bool _isRefreshing = false; // Para el botón de actualizar

  // Variables para la "Última Lectura"
  double _ultimoValor = 0.0;
  String _ultimaFecha = "";
  String _ultimaHora = "";

  final String _defaultApiUrl =
      "https://script.google.com/macros/s/AKfycbygUivdTGdLb_2p7f80TAJiwm_elb7FfXvyIJn_ID-BYhedUWjOQs1Sqk2rmubtn80N/exec";

  @override
  void initState() {
    super.initState();
    _loadApiBaseUrl().then(
      (_) => _actualizarDatos(),
    ); // Llama a la nueva función
    // Aumentamos el timer a 10s para no saturar
    timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _actualizarDatos(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('api_base_url');
    apiBaseUrl = (saved != null && saved.isNotEmpty) ? saved : _defaultApiUrl;
  }

  // --- LÓGICA DE ACTUALIZACIÓN DE DATOS ---

  // Nueva función que se encarga de actualizar todo
  Future<void> _actualizarDatos({bool isManualRefresh = false}) async {
    // Si ya está actualizando, no hace nada
    if (_isRefreshing) return;

    // Solo muestra el indicador si es refrescado manual
    if (isManualRefresh) {
      setState(() => _isRefreshing = true);
    }

    try {
      if (apiBaseUrl != null && apiBaseUrl!.isNotEmpty) {
        await Future.wait([_fetchApiHistory(), _fetchApiLastReading()]);
      } else {
        if (widget.esp32Ip != null && widget.esp32Ip!.isNotEmpty) {
          await _fetchEsp32Reading();
        }
      }
    } catch (e) {
      debugPrint("Error actualizando datos: $e");
    }

    if (isManualRefresh && mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  // Obtiene el historial para el GRÁFICO (endpoint=history)
  Future<void> _fetchApiHistory() async {
    try {
      final uri = Uri.parse(
        '$apiBaseUrl?endpoint=history&type=${widget.tipo}&limit=15',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['points'] != null) {
          final List<dynamic> points = (data['points'] ?? []) as List<dynamic>;
          final List<double> serie = points
              .map((p) => ((p['value'] ?? 0) as num).toDouble())
              .toList();
          if (mounted) {
            setState(() {
              valores = serie;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error en _fetchApiHistory: $e");
    }
  }

  // Obtiene la ÚLTIMA LECTURA con fecha y hora (endpoint=last1min)
  Future<void> _fetchApiLastReading() async {
    try {
      final uri = Uri.parse('$apiBaseUrl?endpoint=last1min');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['fecha'] == null) return; // Respuesta inválida

        double tempValor = 0.0;
        // El script devuelve TODOS los sensores, usamos widget.tipo para elegir
        switch (widget.tipo) {
          case "temperatura":
            tempValor = (data["temperatura"] ?? 0).toDouble();
            break;
          case "humedad": // Mapea al nombre de tu script
            tempValor = (data["humedadAmbiente"] ?? 0).toDouble();
            break;
          case "humedadSuelo":
            tempValor = (data["humedadSuelo"] ?? 0).toDouble();
            break;
          case "ph":
            tempValor = (data["ph"] ?? 0).toDouble();
            break;
          case "tds":
            tempValor = (data["tds"] ?? 0).toDouble();
            break;
          case "uv":
            tempValor = (data["uv"] ?? 0).toDouble();
            break;
        }

        if (mounted) {
          setState(() {
            _ultimoValor = tempValor;
            _ultimaFecha = data['fecha'];
            _ultimaHora = data['hora'];
          });
        }
      }
    } catch (e) {
      debugPrint("Error en _fetchApiLastReading: $e");
    }
  }

  // Lógica original para MODO ESP32
  Future<void> _fetchEsp32Reading() async {
    try {
      final response = await http.get(
        Uri.parse("${widget.esp32Ip}/${widget.tipo}"),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double valor = 0;
        switch (widget.tipo) {
          case "temperatura":
            valor = (data["temperatura"] ?? 0).toDouble();
            break;
          case "humedad":
            valor = (data["humedad"] ?? data["humedadAmbiente"] ?? 0)
                .toDouble();
            break;
          case "ph":
            valor = (data["ph"] ?? 0).toDouble();
            break;
          case "tds":
            valor = (data["tds"] ?? 0).toDouble();
            break;
          case "uv":
            valor = (data["uv"] ?? 0).toDouble();
            break;
        }
        if (mounted) {
          setState(() {
            _ultimoValor = valor; // Actualiza el valor
            _ultimaFecha = ""; // Modo ESP no da fecha/hora
            _ultimaHora = "";
            valores.add(valor); // Actualiza el gráfico
            if (valores.length > 15) valores.removeAt(0);
          });
        }
      }
    } catch (e) {
      debugPrint("Error en _fetchEsp32Reading: $e");
    }
  }

  // Devuelve las unidades correctas para cada sensor
  String _getUnits() {
    switch (widget.tipo) {
      case "temperatura":
        return "°C";
      case "humedad":
      case "humedadSuelo":
        return "%";
      case "ph":
        return " pH";
      case "tds":
        return " ppm";
      default:
        return "";
    }
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ (WIDGETS) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        // No hay botón de PDF en actions
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. NUEVA SECCIÓN DE ÚLTIMA LECTURA
            _buildLastReadingDisplay(),

            const SizedBox(height: 20),

            // 2. GRÁFICO EN TAMAÑO FIJO (1/4 de pantalla aprox)
            _buildChartDisplay(),

            // Empuja el botón al fondo
            const Spacer(),

            // 3. BOTÓN DE ACTUALIZAR
            _buildRefreshButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget para la tarjeta de última lectura
  Widget _buildLastReadingDisplay() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Última Lectura",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            // Valor grande
            Text(
              "${_ultimoValor.toStringAsFixed(2)}${_getUnits()}",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            // Muestra fecha y hora solo si las tenemos (Modo API)
            if (_ultimaFecha.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fecha: $_ultimaFecha"),
                  Text("Hora: $_ultimaHora"),
                ],
              )
            else if (_isRefreshing)
              Text("Buscando datos...")
            else
              Text("Actualizado en tiempo real"),
          ],
        ),
      ),
    );
  }

  // Widget para el gráfico
  Widget _buildChartDisplay() {
    return SizedBox(
      height: 200, // Altura fija (aprox 1/4 de pantalla)
      child: valores.isEmpty
          ? const Center(child: Text("Cargando gráfico..."))
          : LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.2),
                    ),
                    dotData: const FlDotData(show: true),
                    spots: [
                      for (int i = 0; i < valores.length; i++)
                        FlSpot(i.toDouble(), valores[i]),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Widget para el botón de actualizar
  Widget _buildRefreshButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isRefreshing
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.refresh),
        label: const Text("ACTUALIZAR"),
        onPressed: _isRefreshing
            ? null
            : () => _actualizarDatos(isManualRefresh: true),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
