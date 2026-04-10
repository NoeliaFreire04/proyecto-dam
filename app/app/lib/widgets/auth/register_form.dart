import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nombre de usuario',
            labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El nombre de usuario es obligatorio';
            }
            return null;
          },
        ),
        TextFormField(
          controller: emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El email es obligatorio';
            }
            return null;
          },
        ),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La contraseña es obligatoria';
            }
            return null;
          },
        ),
      ],
    );
  }
}