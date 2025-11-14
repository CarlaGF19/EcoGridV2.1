import 'package:flutter/material.dart';
import 'device_config_screen.dart';
import '../widgets/bottom_navigation_widget.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({super.key});

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  bool isConnected = true;
  String deviceIP = "192.168.1.100";
  String wifiSignal = "-45 dBm (Excelente)";
  String connectionTime = "2h 15min";
  String lastCommunication = "hace 30s";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: const Flexible(
          child: Text(
            'Gestión de Dispositivos',
            style: TextStyle(
              color: Color(0xFF498428), // Verde oscuro para el texto
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 16),
            _buildIpConfigButton(),
            const SizedBox(height: 16),
            _buildConnectionStatistics(),
            const SizedBox(height: 16), // Espacio adicional para evitar overflow
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
    );
  }

  Widget _buildConnectionStatus() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Estado de Conexión Principal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              icon: isConnected ? Icons.check_circle : Icons.error,
              color: isConnected ? Colors.green : Colors.red,
              title: 'ESP32 Status',
              value: isConnected ? 'Conectado' : 'Desconectado',
            ),
            _buildStatusItem(
              icon: Icons.location_on,
              color: Colors.blue,
              title: 'IP',
              value: deviceIP,
            ),
            _buildStatusItem(
              icon: Icons.signal_wifi_4_bar,
              color: Colors.green,
              title: 'WiFi',
              value: wifiSignal,
            ),
            _buildStatusItem(
              icon: Icons.access_time,
              color: Colors.orange,
              title: 'Conectado desde',
              value: connectionTime,
            ),
            _buildStatusItem(
              icon: Icons.refresh,
              color: Colors.purple,
              title: 'Última comunicación',
              value: lastCommunication,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpConfigButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const DeviceConfigScreen();
            },
          );
        },
        icon: const Icon(Icons.settings_ethernet),
        label: const Text('Configuración de IP'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }


  Widget _buildConnectionStatistics() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF498428)), // Verde oscuro
                const SizedBox(width: 8),
                const Text(
                  'Estadísticas de Conexión',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatItem('Tiempo total conectado', '8h 42min'),
            _buildStatItem('Desconexiones hoy', '2'),
            _buildStatItem('Uptime', '95.2%'),
            _buildStatItem('Calidad promedio', 'Buena'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title: $value',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required List<String> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2196F3)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(left: 32, top: 2),
                child: Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Dispositivos'),
        content: const Text('Buscando dispositivos IoT en la red...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}