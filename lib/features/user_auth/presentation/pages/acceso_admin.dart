import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_5s/auth/auth_service.dart';
// Singleton for storing tokens globally

final authService = AuthService();

final auth0 = Auth0(
  'dev-aodesvgtpd08tn2z.us.auth0.com',
  'XVv0JTHH67GBp0dtZ6jsJzHJqEj88SlD',
);

class AdminAccessPage extends StatefulWidget {
  const AdminAccessPage({Key? key}) : super(key: key);

  @override
  State<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends State<AdminAccessPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco asegurado
      body: Column(
        children: [
          const SizedBox(height: 150),
          const CircleAvatar(
            radius: 90,
            backgroundColor: Colors.transparent,
            backgroundImage:
                AssetImage('lib/assets/images/AURISISOTIPO-AZUL.png'),
          ),
          const SizedBox(height: 15),
          const Text(
            '¡Bienvenido!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220,
                      child: FilledButton(
                        onPressed: () async {
                          try {
                            final result = await auth0
                                .webAuthentication(
                                  scheme: 'com.example.flutterapp5s',
                                )
                                .login(
                                  audience:
                                      'https://dev-aodesvgtpd08tn2z.us.auth0.com/api/v2/',
                                );
                            // Guarda los tokens y el usuario globalmente
                            authService.accessToken = result.accessToken;
                            authService.idToken = result.idToken;
                            authService.user = result.user;

                            // Ejemplo: llamar a tu backend con el token
                            await getUserRoles(authService.accessToken!);

                            context.goNamed('OrganizationsListPage');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error de login: $e')),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              const Color.fromARGB(255, 49, 136, 235),
                        ),
                        child: const Text(
                          "Acceder",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

Future<void> getUserRoles(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://djnxv2fqbiqog.cloudfront.net/user-roles/myroles'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  print('User Roles response: \\${response.statusCode} - \\${response.body}');
}
