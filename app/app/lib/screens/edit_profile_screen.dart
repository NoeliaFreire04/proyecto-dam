import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

//pantalla para editar el username, email y foto de perfil del usuario
class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;
  final String? currentProfilePicture;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    required this.currentEmail,
    this.currentProfilePicture,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _avatarCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.currentUsername);
    _emailCtrl = TextEditingController(text: widget.currentEmail);
    _avatarCtrl =
        TextEditingController(text: widget.currentProfilePicture ?? '');
    // setState al escribir la URL para refrescar el preview del avatar.
    _avatarCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  //envía los datos al backend; al guardar actualiza también la storage local
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final token = await _storage.read(key: 'token');
      final avatar = _avatarCtrl.text.trim();
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/users/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': _usernameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          // Mandamos string vacío para BORRAR la imagen (el backend lo trata
          // como null). Si dejamos el null en el JSON el backend lo ignora.
          'profilePicture': avatar,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _storage.write(
            key: 'username', value: _usernameCtrl.text.trim());
        await _storage.write(key: 'email', value: _emailCtrl.text.trim());
        await _storage.write(
            key: 'profilePicture', value: avatar.isEmpty ? '' : avatar);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el perfil')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar con el servidor')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C2D4E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildAvatarPreview()),
              const SizedBox(height: 24),
              _buildLabel('FOTO DE PERFIL (URL)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _avatarCtrl,
                style: const TextStyle(color: Color(0xFF0C2D4E)),
                decoration: _fieldDecoration(
                  hint: 'https://... (vacío para quitarla)',
                  suffix: _avatarCtrl.text.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Color(0xFF7A8FA3)),
                          tooltip: 'Quitar foto',
                          onPressed: () => _avatarCtrl.clear(),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('NOMBRE DE USUARIO'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _usernameCtrl,
                style: const TextStyle(color: Color(0xFF0C2D4E)),
                decoration: _fieldDecoration(hint: 'Nombre de usuario'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  if (v.trim().length < 3) {
                    return 'Mínimo 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('CORREO ELECTRÓNICO'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Color(0xFF0C2D4E)),
                decoration: _fieldDecoration(hint: 'correo@ejemplo.com'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El email es obligatorio';
                  }
                  if (!v.contains('@')) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C2D4E),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF0C2D4E).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Vista previa del avatar: si hay URL muestra la imagen, si no las iniciales.
  Widget _buildAvatarPreview() {
    final url = _avatarCtrl.text.trim();
    if (url.isEmpty) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: const Color(0xFF0C2D4E),
        child: Text(
          _initials(_usernameCtrl.text),
          style: const TextStyle(
            color: Color(0xFFF5C518),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFE57373),
          child: const Icon(Icons.broken_image, color: Colors.white),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7A8FA3),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF7A8FA3)),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF0C2D4E).withOpacity(0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF0C2D4E).withOpacity(0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5C518), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE57373), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
