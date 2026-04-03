import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controla si estamos en modo login o registro
  bool _isLogin = true;

  // Controladores para los campos de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Servicio de autenticación
  final AuthService _authService = AuthService();

  // Indica si hay una petición en curso
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2D4E),
      body: SafeArea(
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          
        ],
      ),
    ),
  ),
    );
  }
}