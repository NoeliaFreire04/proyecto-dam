import 'package:flutter/material.dart';

import '../widgets/recipe/create_mode_toggle.dart';
import 'create_recipe/manual_mode_view.dart';
import 'create_recipe/video_mode_view.dart';

/// Pantalla principal del módulo "Crear receta".
/// Contiene el header, el toggle entre modo vídeo (IA) y manual,
/// y la vista correspondiente embebida.
///
/// `startInVideoMode` permite forzar el modo inicial cuando se llega
/// desde la tarjeta amarilla del Feed.
class CreateRecipeScreen extends StatefulWidget {
  final bool startInVideoMode;
  final bool showBackButton;

  const CreateRecipeScreen({
    super.key,
    this.startInVideoMode = true,
    this.showBackButton = false,
  });

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  late bool _videoMode;

  @override
  void initState() {
    super.initState();
    _videoMode = widget.startInVideoMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'CookShare',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showBackButton) _buildBackButton(),
              if (widget.showBackButton) const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 18),
              CreateModeToggle(
                isVideoMode: _videoMode,
                onChanged: (v) => setState(() => _videoMode = v),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _videoMode
                    ? const VideoModeView(key: ValueKey('video'))
                    : const ManualModeView(key: ValueKey('manual')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E0D2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 14, color: Color(0xFF0C2D4E)),
            SizedBox(width: 4),
            Text(
              'volver',
              style: TextStyle(
                color: Color(0xFF0C2D4E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nueva receta',
                style: TextStyle(
                  color: Color(0xFF0C2D4E),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manual o con inteligencia artificial',
                style: TextStyle(color: Color(0xFF7E8A99), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
