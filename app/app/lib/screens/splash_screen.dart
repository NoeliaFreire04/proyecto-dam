import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_screen.dart';
import 'home_screen.dart';

/// Pantalla inicial que decide a qué pantalla ir según haya token o no.
///
/// Si hay un JWT guardado en `FlutterSecureStorage` con la clave `token`,
/// asumimos que el usuario sigue logueado y vamos directos a `HomeScreen`.
/// Si no, mostramos `AuthScreen` para que se loguee.
///
/// Esto se ejecuta tanto al arrancar la app como al refrescar la página
/// en la versión web — así no se pierde la sesión al darle a F5.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _decideStartScreen();
  }

  Future<void> _decideStartScreen() async {
    // Pequeño delay para que el primer frame se renderice antes de navegar
    // (evita un parpadeo feo del MaterialApp inicial).
    await Future.delayed(const Duration(milliseconds: 50));

    String? token;
    try {
      token = await _storage.read(key: 'token');
    } catch (_) {
      // En web, FlutterSecureStorage puede fallar la primera vez si no
      // hay datos. Lo tratamos como "no hay token".
      token = null;
    }

    if (!mounted) return;

    final hasToken = token != null && token.isNotEmpty;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasToken ? const HomeScreen() : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI mínima: el fondo de la app y un spinner amarillo mientras
    // decidimos dónde mandar al usuario.
    return const Scaffold(
      backgroundColor: Color(0xFF0C2D4E),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFF5C518)),
      ),
    );
  }
}
