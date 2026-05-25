import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

//punto de entrada de la app, inicializa Flutter y arranca todo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

//widget raíz que configura el tema y arranca en la SplashScreen, que decide
//si llevar al usuario al login o directamente a HomeScreen según haya token
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
      //SplashScreen lee el token y redirige a HomeScreen o AuthScreen
      home: const SplashScreen(),
    );
  }
}
