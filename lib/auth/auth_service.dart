import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? accessToken;
  String? idToken;
  UserProfile? user; // <-- Cambia aquí el tipo
  String? organizationId; // ID de la organización seleccionada

  Future<void> logout() async {
    try {
      final auth0 = Auth0(
        'dev-aodesvgtpd08tn2z.us.auth0.com',
        'XVv0JTHH67GBp0dtZ6jsJzHJqEj88SlD',
      );
      await auth0
          .webAuthentication(
              // scheme: 'com.example.flutterapp5s'
              )
          .logout();
      // Limpiar los datos de la sesión
      accessToken = null;
      idToken = null;
      user = null;
      organizationId = null; // También limpiamos el ID de la organización
    } catch (e) {
      print('Error durante el logout: $e');
      rethrow;
    }
  }
}

final authService = AuthService();
