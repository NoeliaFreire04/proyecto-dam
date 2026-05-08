//modelo que guarda los datos de sesión que devuelve la API al autenticarse
class SessionModel {
    final String email;
    final String tokenJWT;

    SessionModel({required this.email, required this.tokenJWT});

    //construye el modelo a partir del JSON que devuelve la API
    factory SessionModel.fromJson(Map<String, dynamic> json) {
        return SessionModel(
            email: json['email'],
            tokenJWT: json['tokenJWT'],
        );
    }
}
