import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/register_form.dart';
import '../widgets/auth/auth_button.dart';
import '../screens/home_screen.dart';

//pantalla de autenticación que permite al usuario iniciar sesión o registrarse
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controla si estamos en modo login o registro
  bool _isLogin = true;

  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Servicio de autenticación
  final AuthService _authService = AuthService();

  // Indica si hay una petición en curso
  bool _isLoading = false;

  //Instancia de SecureStorage para guardar el token generado
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  //cambia entre modo login y modo registro
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  //valida el formulario y llama al servicio de login o registro según el modo activo
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_isLogin) {
          final session = await _authService.login(
            _emailController.text,
            _passwordController.text,
          );
          //guarda el token y el email para usarlos en peticiones autenticadas
          await _storage.write(key: 'token', value: session.tokenJWT);
          await _storage.write(key: 'email', value: session.email);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          final session = await _authService.register(
            _usernameController.text,
            _emailController.text,
            _passwordController.text,
          );
          //guarda el token, el email y el nombre de usuario tras el registro
          await _storage.write(key: 'token', value: session.tokenJWT);
          await _storage.write(key: 'email', value: session.email);
          await _storage.write(key: 'username', value: _usernameController.text);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (e) {
        //muestra un mensaje de error si el login o el registro fallan
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLogin
                  ? 'Email o contraseña incorrectos'
                  : 'Error al registrarse. Comprueba los datos'),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2D4E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //logo centrado en la parte superior
              const Center(child: AuthLogo()),
              const SizedBox(height: 36),
              //título que cambia según el modo activo
              Text(
                _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              //formulario de login o registro según el modo activo
              Form(
                key: _formKey,
                child: _isLogin
                    ? LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                      )
                    : RegisterForm(
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),
              ),
              const SizedBox(height: 28),
              //botón de acción y enlace para cambiar de modo
              AuthButton(
                isLogin: _isLogin,
                isLoading: _isLoading,
                onPressed: _submit,
                onToggle: _toggleMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
