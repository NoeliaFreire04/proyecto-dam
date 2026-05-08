import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

//punto de entrada de la app, inicializa Flutter y arranca todo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

//widget raíz que configura el tema y apunta a la pantalla de login como inicio
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C2D4E)),
      ),
      //siempre empieza en la pantalla de autenticación
      home: const AuthScreen(),
    );
  }
}
