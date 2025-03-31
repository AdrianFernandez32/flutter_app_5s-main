// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/utils/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
                        onPressed: () {
                          context.goNamed(
                              'CreateOrganization'); // Redirige directamente a la vista principal
                        },
                        child: const Text(
                          "Iniciar Sesión",
                          style: TextStyle(fontSize: 16),
                        ),
                        // onPressed: () async {
                        //   final isValid = _formkey.currentState?.validate();
                        //   if (isValid != true) {
                        //     return;
                        //   }
                        //   try {
                        //     final AuthResponse response =
                        //         await client.auth.signInWithPassword(
                        //       email: _emailController.text,
                        //       password: _passwordController.text,
                        //     );
                        //     // if (response.session != null) {
                        //     //   context.goNamed('Menu');
                        //     // }
                        //   } catch (e) {
                        //     // ignore: use_build_context_synchronously
                        //     ScaffoldMessenger.of(context)
                        //         .showSnackBar(const SnackBar(
                        //       content: Text('Log-in failed'),
                        //       backgroundColor: Colors.redAccent,
                        //     ));
                        //   }

                        //   //Navigator.of(context).pushReplacementNamed('/menu');
                        // },
                        // child: const Text(
                        //   "Iniciar Sesión",
                        //   style: TextStyle(fontSize: 16),
                        // )),
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
