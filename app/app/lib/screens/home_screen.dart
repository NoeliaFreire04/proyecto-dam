import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2D4E),
      body: const Center(
        child: Text(
          '¡Bienvenido a CookShare!',
          style: TextStyle(
            color: Color(0xFFF5F0E8),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}