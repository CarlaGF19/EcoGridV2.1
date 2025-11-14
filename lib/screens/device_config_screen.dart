import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceConfigScreen extends StatefulWidget {
  const DeviceConfigScreen({super.key});

  @override
  State<DeviceConfigScreen> createState() => _DeviceConfigScreenState();
}

class _DeviceConfigScreenState extends State<DeviceConfigScreen> {
  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _ipController.text = prefs.getString("esp32_ip") ?? "";
  }

  Future<void> _saveIp() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("esp32_ip", ip);

    if (!mounted) return;
    context.go('/main-menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco (consistente con MainMenu)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Esquinas completamente rectas
        ),
        clipBehavior: Clip.none, // Sin recorte que pueda crear bordes redondeados
        title: const Text(
          "Configurar IP del ESP32",
          style: TextStyle(color: Color(0xFF004C3F)), // Verde oscuro del MainMenu
        ),
        iconTheme: const IconThemeData(color: Color(0xFF004C3F)), // Verde oscuro del MainMenu
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Ingresa la dirección IP del ESP32",
              style: TextStyle(
                color: Color(0xFF004C3F), // Verde oscuro del MainMenu
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "Ejemplo: http://192.168.1.10",
                labelStyle: TextStyle(color: Color(0xFF009E73)), // Verde secundario del MainMenu
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00E0A6), width: 2), // Mint del MainMenu en foco
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00B7B0)), // Teal del MainMenu en reposo
                ),
              ),
              style: const TextStyle(color: Color(0xFF004C3F)), // Verde oscuro del MainMenu para el texto
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveIp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B7B0), // Teal del MainMenu
                foregroundColor: Colors.white, // Texto blanco
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Guardar y continuar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
