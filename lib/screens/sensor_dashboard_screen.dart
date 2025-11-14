import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sensor_detail_page.dart';
import '../widgets/bottom_navigation_widget.dart';

class SensorDashboardScreen extends StatefulWidget {
  final String ip;

  const SensorDashboardScreen({super.key, required this.ip});

  @override
  State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  String? esp32Ip;
  // Eliminados controles de filtros (año/hora) según requerimiento
  // Eliminamos el contador de imágenes del dashboard de sensores para respetar la separación de pestañas

  @override
  void initState() {
    super.initState();
    esp32Ip = widget.ip.isNotEmpty ? widget.ip : null;
    _loadIp();
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      esp32Ip = prefs.getString("esp32_ip");
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  // Eliminado validador de año


  Future<void> _setIpDialog() async {
    final TextEditingController controller = TextEditingController(
      text: esp32Ip ?? "",
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Configurar IP del ESP32"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Dirección IP",
              hintText: "http://192.168.x.xxx",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("esp32_ip", controller.text.trim());
                setState(() {
                  esp32Ip = controller.text.trim();
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _abrirSensor(String tipo, String titulo) {
    if (esp32Ip == null || esp32Ip!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero configura la IP del ESP32")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SensorDetailPage(esp32Ip: esp32Ip!, tipo: tipo, titulo: titulo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 2,
        title: const Text(
          'Dashboard de Sensores',
          style: TextStyle(
            color: Color(0xFF009E73),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00E0A6)),
          onPressed: () {
            // Usar pop para evitar conflictos con Navigator.push desde MainMenu
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00E0A6)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Eliminada barra de entrada de año/hora
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.90,
                children: [
                  SensorCardWithImage(
                    titulo: "TEMPERATURA",
                    imagePath: "assets/images/sensor_dashboard/s_temp.png",
                    onTap: () => _abrirSensor("temperatura", "Temperatura"),
                  ),
                  SensorCardWithImage(
                    titulo: "HUMEDAD",
                    imagePath: "assets/images/sensor_dashboard/s_humedad.png",
                    onTap: () => _abrirSensor("humedad", "Humedad"),
                  ),
                  SensorCardWithImage(
                    titulo: "PH",
                    imagePath: "assets/images/sensor_dashboard/s_ph.png",
                    onTap: () => _abrirSensor("ph", "pH"),
                  ),
                  SensorCardWithImage(
                    titulo: "TDS",
                    imagePath: "assets/images/sensor_dashboard/s_tds.png",
                    onTap: () => _abrirSensor("tds", "TDS"),
                  ),
                  SensorCardWithImage(
                    titulo: "UV",
                    imagePath: "assets/icons/sensor_s.png",
                    onTap: () => _abrirSensor("uv", "UV"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Mantener el BottomNavigation, resaltando Home para coherencia
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final VoidCallback onTap;

  const SensorCard({
    super.key,
    required this.titulo,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6FFF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF009E73), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 160, 120, 0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFF009E73),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Icon(icono, color: Color(0xFF00E0A6), size: 36),
              const SizedBox(height: 10),
              SensorActionInfo(label: 'Show Details'),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorCardWithImage extends StatefulWidget {
  final String titulo;
  final String imagePath;
  final VoidCallback onTap;

  const SensorCardWithImage({
    super.key,
    required this.titulo,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<SensorCardWithImage> createState() => _SensorCardWithImageState();
}

class _SensorCardWithImageState extends State<SensorCardWithImage> {
  bool _isHovered = false;
  bool _isPressed = false;

  // Paletas por sensor (Cristales Sensoriales)
  List<Color> _gradientFor(String titulo) {
    switch (titulo.toUpperCase()) {
      case 'TEMPERATURA':
        return const [Color(0xFFFFE29F), Color(0xFFFFA62E)];
      case 'HUMEDAD':
        return const [Color(0xFF89F7FE), Color(0xFF66A6FF)];
      case 'PH':
        return const [Color(0xFFA18CD1), Color(0xFFFBC2EB)];
      case 'TDS':
      case 'PPM':
        return const [Color(0xFF2BC0E4), Color(0xFFEAECC6)];
      case 'UV':
        return const [Color(0xFFFFC0CB), Color(0xFFFF9AA2)];
      default:
        return const [Color(0xFF00E0A6), Color(0xFF00B894)]; // fallback mint
    }
  }

  Color _accentFor(String titulo) {
    switch (titulo.toUpperCase()) {
      case 'TEMPERATURA':
        return const Color(0xFFFFBE50);
      case 'HUMEDAD':
        return const Color(0xFF66A6FF);
      case 'PH':
        return const Color(0xFFF199FB);
      case 'TDS':
      case 'PPM':
        return const Color(0xFF2BC0E4);
      case 'UV':
        return const Color(0xFFFF737A);
      default:
        return const Color(0xFF00E0A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 700; // tablet/desktop
    // Base tipográfica como unidad relativa (em/rem aproximado)
    final double baseEm = 14 * MediaQuery.of(context).textScaleFactor;
    // Imagen proporcional al ancho de pantalla, con límites para consistencia
    final double iconSize = (size.width * 0.18).clamp(96.0, isWide ? 132.0 : 120.0);
    final List<Color> gradColors = _gradientFor(widget.titulo);
    final Color baseColor = gradColors.first;
    final Color accentColor = _accentFor(widget.titulo);
    // Sombras exteriores con relieve dinámico en hover/press (sin cambiar colores).
    final List<BoxShadow> outerShadows = [
      BoxShadow(
        color: baseColor.withOpacity(0.28),
        blurRadius: _isPressed ? 20 : (_isHovered ? 28 : 24),
        offset: Offset(0, _isPressed ? 6 : 8),
      ),
      BoxShadow(
        color: baseColor.withOpacity(0.16),
        blurRadius: _isPressed ? 10 : (_isHovered ? 16 : 12),
        offset: Offset(0, _isPressed ? 3 : 4),
      ),
      if (_isHovered)
        BoxShadow(
          color: accentColor.withOpacity(0.35),
          blurRadius: 22,
          spreadRadius: 2,
          offset: const Offset(0, 0),
        ),
    ];
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        // Mantener el estado presionado un poco más para que el brillo se perciba
        onTapUp: (_) {
          Future.delayed(const Duration(milliseconds: 220), () {
            if (mounted) setState(() => _isPressed = false);
          });
        },
        // Brillo al pasar con gesto táctil (sin necesidad de tap)
        onPanStart: (_) => setState(() => _isHovered = true),
        onPanUpdate: (_) => setState(() => _isHovered = true),
        onPanEnd: (_) => setState(() => _isHovered = false),
        onTap: () {
          // Sonido de tap sin modificar colores ni temas
          SystemSound.play(SystemSoundType.click);
          // Retrasar navegación para que el glow/flash se vea claramente
          Future.delayed(const Duration(milliseconds: 220), () {
            widget.onTap();
          });
        },
        child: AnimatedScale(
          // Prioriza press sobre hover; sin cambios de color
          scale: _isPressed ? 0.985 : (_isHovered ? 1.03 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 240),
          decoration: BoxDecoration(
            // Degradado metálico-luminoso premium
            gradient: LinearGradient(
              begin: _isHovered
                  ? const Alignment(-0.75, -0.85)
                  : const Alignment(-0.6, -0.7),
              end: _isHovered
                  ? const Alignment(0.95, 0.85)
                  : const Alignment(0.9, 0.8),
              colors: gradColors,
              stops: gradColors.length == 3
                  ? const [0.0, 0.5, 1.0]
                  : const [0.0, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white
                  .withOpacity(_isPressed ? 1.0 : (_isHovered ? 0.85 : 0.75)),
              width: _isPressed ? 3.0 : (_isHovered ? 2.0 : 1.8),
            ),
            boxShadow: _isPressed
                ? [
                    ...outerShadows,
                    BoxShadow(
                      color: Colors.white.withOpacity(0.45),
                      blurRadius: 42,
                      spreadRadius: 2.8,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.18),
                      blurRadius: 64,
                      spreadRadius: 6.0,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : outerShadows,
          ),
          child: Stack(
            children: [
              // Contenido principal en columnas: imagen arriba, título y texto abajo
              Padding(
                // Padding proporcional al tamaño de fuente para mantener respiración visual
                padding: EdgeInsets.symmetric(
                  horizontal: baseEm * 1.2,
                  vertical: baseEm * 1.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Ícono arriba-izquierda con glow suave
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Sombra circular suave bajo el ícono, tono del cristal
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: baseColor.withOpacity(0.22),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                          AnimatedScale(
                            duration: const Duration(milliseconds: 160),
                            scale: _isHovered ? 1.03 : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: baseColor.withOpacity(0.18),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                widget.imagePath,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.broken_image,
                                    color: baseColor,
                                    size: iconSize,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Separación proporcional entre imagen y texto
                    SizedBox(height: baseEm * 0.8),
                    // Título y acción abajo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Asegura ancho fijo y truncado seguro del título
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            widget.titulo,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.1,
                              shadows: [
                                Shadow(
                                  color: accentColor.withOpacity(0.35),
                                  blurRadius: 2.0,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: baseEm * 0.6),
                        SensorActionInfo(
                          label: 'Show Details',
                          glowColor: accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Reflejo especular suave en diagonal (de arriba izq a abajo der)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: _isHovered
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        end: _isHovered
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        colors: [
                          Colors.white.withOpacity(
                              _isPressed ? 0.52 : (_isHovered ? 0.34 : 0.28)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Brillo radial en la esquina superior izquierda (20% 20%)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 0.8,
                        colors: [
                          Colors.white.withOpacity(0.32),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Luz ambiental inferior simulando inset (brillo reflejado del sensor)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          accentColor.withOpacity(_isPressed ? 0.55 : 0.35),
                          Colors.transparent,
                        ],
                        stops: _isPressed
                            ? const [0.0, 0.35]
                            : const [0.0, 0.25],
                      ),
                    ),
                  ),
                ),
              ),

              
              // Eliminada sombra interna gris para evitar opacidad no deseada
              // Halo interno extra en hover para simular "energía activa"
              if (_isHovered)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            accentColor.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Flash sutil al presionar (más brillo temporal sin cambiar paleta)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _isPressed ? 0.28 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const RadialGradient(
                          center: Alignment.center,
                          radius: 0.85,
                          colors: [
                            Color.fromARGB(255, 255, 255, 255),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// Botón reutilizable tipo "píldora" para el Sensor Dashboard
class SensorActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const SensorActionButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<SensorActionButton> createState() => _SensorActionButtonState();
}

class _SensorActionButtonState extends State<SensorActionButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFF009E73);
    const Color bgBase = Color(0xFFE6FFF5); // fondo mint claro
    const Color bgHover = Color(0xFF6DFFF5); // hover mint
    final Color textColor = borderColor;
    final Color bg = _hovering ? bgHover : bgBase;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 160, 120, 0.15),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          transform: Matrix4.identity()..scale(_pressed ? 0.98 : 1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen pequeña dentro del botón
              Image.asset('assets/icons/sensor_s.png', width: 22, height: 22),
              const SizedBox(width: 8),
              // Texto principal + mini texto
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'detalles',
                      style: TextStyle(
                        color: const Color(0xFF009E73).withOpacity(0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bloque informativo no interactivo (imagen + texto + mini texto)
class SensorActionInfo extends StatelessWidget {
  final String label;
  final Color? glowColor; // opcional: brillo acorde al color dominante
  const SensorActionInfo({super.key, required this.label, this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.70),
        fontWeight: FontWeight.w700,
        fontSize: 13,
        shadows: [
          Shadow(
            color: (glowColor ?? const Color(0xFF00E0A6)).withOpacity(0.35),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}

// Eliminado el formateador de hora HH:MM según requerimiento

// Tarjeta de total de imágenes eliminada del sensor dashboard (se moverá a la galería)
