import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../models/recipe_model.dart';
import '../../services/recipe_service.dart';
import '../recipe_detail_screen.dart';

/// Vista del modo "Crear receta desde vídeo" con Google Gemini.
/// Permite seleccionar un fichero (MP4/MOV/AVI, ≤ 50 MB), valida
/// extensión y tamaño, y lo manda al backend para análisis.
class VideoModeView extends StatefulWidget {
  const VideoModeView({super.key});

  @override
  State<VideoModeView> createState() => _VideoModeViewState();
}

class _VideoModeViewState extends State<VideoModeView> {
  static const int _maxBytes = 50 * 1024 * 1024; // 50 MB
  static const List<String> _allowedExtensions = ['mp4', 'mov', 'avi'];

  final RecipeService _service = RecipeService();

  PlatformFile? _selectedFile;
  bool _analyzing = false;

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        // En web el path no existe, hay que pedir bytes. En móvil/desktop
        // usamos path normal (más eficiente, no carga todo en memoria).
        withData: kIsWeb,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.size > _maxBytes) {
        _showError('El vídeo supera los 50 MB');
        return;
      }
      final ext = (file.extension ?? '').toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        _showError('Formato no soportado. Usa MP4, MOV o AVI.');
        return;
      }
      setState(() => _selectedFile = file);
    } catch (_) {
      _showError('No se pudo seleccionar el vídeo');
    }
  }

  Future<void> _analyze() async {
    final file = _selectedFile;
    if (file == null) {
      _showError('Selecciona un vídeo primero');
      return;
    }
    // En web miramos bytes; en móvil miramos path
    if (kIsWeb && file.bytes == null) {
      _showError('No se pudo leer el vídeo seleccionado');
      return;
    }
    if (!kIsWeb && file.path == null) {
      _showError('No se pudo leer el vídeo seleccionado');
      return;
    }

    setState(() => _analyzing = true);
    try {
      final Recipe created = await _service.createFromVideo(
        filePath: kIsWeb ? null : file.path,
        bytes: kIsWeb ? file.bytes : null,
        fileName: file.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta creada desde el vídeo')),
      );

      // Limpiamos el fichero seleccionado para dejar la vista lista
      // para procesar otro vídeo si el usuario vuelve atrás.
      setState(() => _selectedFile = null);

      // Usamos push (no pushReplacement) porque esta vista vive dentro
      // del tab "Crear" del IndexedStack del HomeScreen. Con
      // pushReplacement reemplazaríamos la HomeScreen entera y al volver
      // atrás se quedaría la app en blanco.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: created),
        ),
      );
    } catch (e) {
      // Mostramos el mensaje real del backend (rate limit, API key, etc.)
      String msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.length > 200) msg = msg.substring(0, 200);
      _showError(msg.isEmpty ? 'Error al analizar el vídeo' : msg);
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C2D4E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeminiBadge(),
          const SizedBox(height: 16),
          const Text(
            'Sube un vídeo de tu receta',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gemini analiza el vídeo y extrae automáticamente el título, '
            'ingredientes y pasos de elaboración.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          _buildDropZone(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_selectedFile == null || _analyzing) ? null : _analyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C518),
                foregroundColor: const Color(0xFF0C2D4E),
                disabledBackgroundColor: const Color(0xFFF5C518).withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              child: _analyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF0C2D4E),
                      ),
                    )
                  : const Text('Analizar vídeo con IA'),
            ),
          ),
          const SizedBox(height: 12),
          _buildFormatChips(),
          const SizedBox(height: 12),
          const Text(
            'El análisis tarda hasta 30 segundos.\n'
            'Podrás editar el borrador antes de guardar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiBadge() {
    // FittedBox con scaleDown garantiza que si la pantalla es muy estrecha
    // el badge se redimensione en lugar de desbordarse. Wrap por fuera
    // evita que ocupe todo el ancho disponible.
    return Wrap(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5C518),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF0C2D4E), size: 14),
                SizedBox(width: 4),
                Text(
                  'Google Gemini',
                  style: TextStyle(
                    color: Color(0xFF0C2D4E),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone() {
    final hasFile = _selectedFile != null;
    return GestureDetector(
      onTap: _analyzing ? null : _pickVideo,
      child: DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              Icon(
                hasFile ? Icons.check_circle : Icons.upload_file,
                color: const Color(0xFFF5C518),
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                hasFile
                    ? _selectedFile!.name
                    : 'Arrastra tu vídeo aquí\no pulsa para seleccionar',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasFile
                    ? _formatSize(_selectedFile!.size)
                    : 'MP4, MOV o AVI · máx. 50 MB',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChips() {
    return Wrap(
      spacing: 6,
      children: const [
        _Chip(label: 'MP4'),
        _Chip(label: 'MOV'),
        _Chip(label: 'AVI'),
        _Chip(label: '≤ 50 MB'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Caja con borde discontinuo amarillo (efecto "drag & drop").
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        color: const Color(0xFFF5C518).withOpacity(0.6),
        strokeWidth: 1.4,
        gap: 5,
        radius: 14,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          color: const Color(0xFF0A2240),
          child: child,
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next =
            (distance + gap).clamp(0.0, metric.length).toDouble();
        dashed.addPath(
          metric.extractPath(distance, next),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
