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
          decoration: InputDecoration(
            labelText: 'Nombre de usuario',
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
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
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
          decoration: InputDecoration(
            labelText: 'Contraseña',
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