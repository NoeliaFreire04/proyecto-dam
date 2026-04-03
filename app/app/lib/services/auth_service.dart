import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/session_model.dart';

class AuthService{
  Future<SessionModel> register(String username, String email, String password) async{
    //Petición POST con los datos para el registro, enviados en formato JSON
    final response = await http.post(
      //URL de la API
      Uri.parse('${AppConstants.baseUrl}/auth/register'),
      //Cabecera, indica en que formato se envía la información
      headers: {'Content-Type':'application/json'},
      //Cuerpo del JSON a enviar
      body: jsonEncode({
        'username':username,
        'email':email,
        'password':password
        }
      )
    );
    //Verificamos que la petición fue exitosa y añadimos los datos al modelo
    if (response.statusCode == 201) {
      return SessionModel.fromJson(jsonDecode(response.body));
    } else {
      //Si la petición no fue exitosa se lanza una excepción
      throw Exception('Error al registrarse');
    }
  }
  Future<SessionModel> login(String email, String password) async{
    //Petición POST con los datos para el login, enviados en formato JSON
    final response = await http.post(
      //URL de la API
      Uri.parse('${AppConstants.baseUrl}/auth/login'),
      //Cabecera, indica en que formato se envía la información
      headers: {'Content-Type':'application/json'},
      //Cuerpo del JSON a enviar
      body: jsonEncode({
        'email':email,
        'password':password
        }
      )
    );
    //Verificamos que la petición fue exitosa y añadimos los datos al modelo
    if (response.statusCode == 200) {
      return SessionModel.fromJson(jsonDecode(response.body));
    } else {
      //Si la petición no fue exitosa se lanza una excepción
      throw Exception('Error al registrarse');
    }
  }
}