// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:http/http.dart' as http;

// Reemplaza estos valores con los de tu Auth0
final auth0 = Auth0(
  'dev-aodesvgtpd08tn2z.us.auth0.com', // Nuevo dominio de Auth0
  'XVv0JTHH67GBp0dtZ6jsJzHJqEj88SlD', // Nuevo clientId de Auth0
);

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final backgroundColor = const Color.fromARGB(255, 255, 220, 193);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Form(
        key: _formkey,
        child: Scaffold(
          body: Container(
            color: backgroundColor,
            child: Container(
              //color: Colors.amber,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/assets/images/background_login.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      Image.asset(
                        "lib/assets/images/login_logo.png",
                        height: 160,
                        width: 160,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un correo por favor.';
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Correo",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese una contraseña por favor.';
                            }
                            return null;
                          },
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      FilledButton(
                        onPressed: () async {
                          try {
                            final result = await auth0.webAuthentication().login(
                              audience: 'https://dev-aodesvgtpd08tn2z.us.auth0.com/api/v2/',
                              parameters: {
                                'login_hint': _emailController.text,
                              },
                            );
                            // Aquí tienes el token de usuario:
                            final idToken = result.idToken;
                            final accessToken = result.accessToken;
                            final user = result.user; // Info del usuario

                            // Puedes guardar el token en memoria o en storage seguro
                            // Y luego usarlo para llamar a tu backend

                            // Ejemplo: llamar a tu backend con el token
                            await callBackendApi(accessToken);

                            // Redirige a la pantalla principal
                            context.goNamed('Menu');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error de login: $e')),
                            );
                          }
                        },
                        child: const Text("Iniciar Sesión"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      OutlinedButton(
                          onPressed: () async {
                            context.goNamed("Account");
                            //Navigator.of(context).pushReplacementNamed('/signin');
                          },
                          child: const Text("Registrarte")),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> callBackendApi(String accessToken) async {
  final response = await http.get(
    Uri.parse('https://djnxv2fqbiqog.cloudfront.net/user/whoami'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    // Usuario autenticado correctamente
    print('Usuario: ${response.body}');
  } else {
    // Error de autenticación
    print('Error: ${response.body}');
  }
}
