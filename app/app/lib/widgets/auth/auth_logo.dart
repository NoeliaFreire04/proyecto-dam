import 'package:flutter/material.dart';

//logo y nombre de la app para mostrar en la pantalla de autenticación
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //imagen del logo cargada desde assets
        Image.asset(
          'assets/images/logo.png',
          height: 100,
        ),
        const SizedBox(height: 12),
        const Text(
          'CookShare',
          style: TextStyle(
            color: Color(0xFFF5F0E8),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Comparte lo que cocinas',
          style: TextStyle(
            color: Color(0xFF7A8FA3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
