import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/auth/auth_logo.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/register_form.dart';
import '../widgets/auth/auth_button.dart';
import '../screens/home_screen.dart';

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

  void _toggleMode(){
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_isLogin) {
        final token = await _authService.login(
          _emailController.text, 
          _passwordController.text);
        await _storage.write(key: 'token', value: token.tokenJWT);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        }else{
          final token = await _authService.register(
            _usernameController.text,
            _emailController.text,
            _passwordController.text);
          await _storage.write(key: 'token', value: token.tokenJWT);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLogin 
              ? 'Email o contraseña incorrectos' 
              : 'Error al registrarse. Comprueba los datos'),
          ),
        );
      }finally{
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          AuthLogo(),
          SizedBox(height: 32,),
          Form(
            key: _formKey,
            child: _isLogin ? 
              LoginForm(emailController: _emailController, passwordController: _passwordController) 
              : RegisterForm(usernameController: _usernameController, emailController: _emailController, passwordController: _passwordController)
          ),
          SizedBox(height: 24,),
          AuthButton(
            isLogin: _isLogin, 
            isLoading: _isLoading, 
            onPressed: _submit, 
            onToggle: _toggleMode)
        ],
      ),
    ),
  ),
    );
  }
}