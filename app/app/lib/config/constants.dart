//constantes de configuración globales de la app
class AppConstants {
  // URL base de la API. Se puede sobreescribir al compilar con:
  //   flutter build apk --dart-define=API_URL=https://tu-servidor.railway.app/api
  // En desarrollo usa la IP local por defecto.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.56.1:8080/api',
  );
}
