import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

//botón de acción, términos de uso (solo en registro) y enlace para cambiar de modo
class AuthButton extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onPressed;
  final VoidCallback onToggle;

  const AuthButton({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onPressed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //botón principal, ancho completo y se deshabilita mientras carga
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8C55A),
              foregroundColor: const Color(0xFF0C2D4E),
              disabledBackgroundColor: const Color(0xFFE8C55A).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFF0C2D4E),
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        //términos de uso solo visibles en el modo de registro
        if (!isLogin) ...[
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF7A8FA3), fontSize: 11),
              children: [
                const TextSpan(text: 'Al registrarte aceptas los '),
                TextSpan(
                  text: 'Términos de uso',
                  style: const TextStyle(color: Color(0xFFE8C55A)),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' y la '),
                TextSpan(
                  text: 'Política de privacidad',
                  style: const TextStyle(color: Color(0xFFE8C55A)),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        //enlace para cambiar entre login y registro
        RichText(
          text: TextSpan(
            text: isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
            style: const TextStyle(color: Color(0xFF7A8FA3), fontSize: 14),
            children: [
              TextSpan(
                text: isLogin ? 'Regístrate' : 'Inicia sesión',
                style: const TextStyle(
                  color: Color(0xFFE8C55A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                recognizer: TapGestureRecognizer()..onTap = onToggle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
