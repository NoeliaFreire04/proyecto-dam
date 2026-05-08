import 'package:flutter/material.dart';

//formulario de login con etiquetas en mayúsculas, iconos y toggle de contraseña
class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 8),
        //enlace para recuperar la contraseña
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Color(0xFFE8C55A), fontSize: 13),
            ),
          ),
        ),
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
