import 'package:flutter/material.dart';

//formulario de registro con etiquetas, iconos, toggle y medidor de seguridad de contraseña
class RegisterForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const RegisterForm({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_checkPasswordStrength);
    super.dispose();
  }

  //calcula la fortaleza de la contraseña según longitud, mayúsculas/números y símbolos
  void _checkPasswordStrength() {
    final pwd = widget.passwordController.text;
    if (pwd.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _strengthLabel = '';
        _strengthColor = Colors.transparent;
      });
      return;
    }
    double strength = 0;
    if (pwd.length >= 8) strength += 0.33;
    if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[0-9]').hasMatch(pwd)) strength += 0.33;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd)) strength += 0.34;

    setState(() {
      _passwordStrength = strength;
      if (strength < 0.34) {
        _strengthLabel = 'Contraseña débil';
        _strengthColor = const Color(0xFFE57373);
      } else if (strength < 0.67) {
        _strengthLabel = 'Contraseña media';
        _strengthColor = const Color(0xFFE8C55A);
      } else {
        _strengthLabel = 'Contraseña segura';
        _strengthColor = const Color(0xFF4CAF50);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //campo de nombre de usuario
        _buildLabel('NOMBRE DE USUARIO'),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(
            hint: 'noelia_chef',
            suffix: const Icon(Icons.person_outline, color: Color(0xFF7A8FA3), size: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'El nombre de usuario es obligatorio';
            return null;
          },
        ),
        const SizedBox(height: 16),
        //campo de email
        _buildLabel('CORREO ELECTRÓNICO'),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(
            hint: 'correo@ejemplo.com',
            suffix: const Icon(Icons.email_outlined, color: Color(0xFF7A8FA3), size: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'El email es obligatorio';
            return null;
          },
        ),
        const SizedBox(height: 16),
        //campo de contraseña con toggle para mostrar u ocultar
        _buildLabel('CONTRASEÑA'),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(
            hint: '••••••••',
            suffix: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF7A8FA3),
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
            return null;
          },
        ),
        //indicador de fortaleza de la contraseña
        if (_passwordStrength > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: const Color(0xFF0A2240),
              valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _strengthLabel,
            style: TextStyle(color: _strengthColor, fontSize: 11),
          ),
        ],
      ],
    );
  }

  //etiqueta en mayúsculas que va encima de cada campo
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

  //decoración común para todos los campos del formulario
  InputDecoration _fieldDecoration({required String hint, required Widget suffix}) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF0A2240),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF4A6A84)),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8C55A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE57373), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
