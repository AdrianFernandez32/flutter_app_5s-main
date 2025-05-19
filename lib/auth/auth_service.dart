import 'package:auth0_flutter/auth0_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? accessToken;
  String? idToken;
  UserProfile? user; // <-- Cambia aquí el tipo
}

final authService = AuthService();