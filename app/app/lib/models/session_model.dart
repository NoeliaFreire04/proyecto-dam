class SessionModel {
    final String email;
    final String tokenJWT;

    SessionModel({required this.email, required this.tokenJWT});

    factory SessionModel.fromJson(Map<String, dynamic> json) {
        return SessionModel(
            email: json['email'],
            tokenJWT: json['tokenJWT'],
        );
    }
}