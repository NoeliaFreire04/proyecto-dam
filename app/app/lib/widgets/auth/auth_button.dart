import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class AuthButton extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final VoidCallback onPressed;
  final VoidCallback onToggle;

  const AuthButton(
    {super.key,
    required this.isLogin,
    required this.isLoading,
    required this.onPressed,
    required this.onToggle
    }
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onPressed, 
          child: isLoading ? CircularProgressIndicator() : Text(isLogin ? 'Iniciar sesión' : 'Registrarse')
        ),
        SizedBox(height: 12,),
        RichText(
            text: TextSpan(
              text: isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes cuenta? ',
              style: TextStyle(color: Color(0xFF7A8FA3)),
              children: [
                TextSpan(
                  text: isLogin ? 'Regístrate' : 'Inicia sesión',
                  style: TextStyle(
                    color: Color(0xFFE8C55A),
                    fontWeight: FontWeight.bold,
                  ),
                  //Permite que el texto de 'Registrate' sea clickable
                  recognizer: TapGestureRecognizer()..onTap = onToggle,
                ),
              ],
            ),
          )
      ],
    );
  }
}