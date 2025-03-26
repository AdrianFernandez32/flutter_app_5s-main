import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_5s/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  final backgroundColor = const Color.fromARGB(255, 255, 220, 193);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Container(
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
                  const SizedBox(
                    width: 250,
                    height: 75,
                    child: Text(
                      "Confirmar Correo",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        label: Text("Email"), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 60,),
                  FilledButton(
                    onPressed: () async {
                      try {
                        final email = _emailController.text.trim();
                        await supabase.auth.signInWithOtp(
                            email: email,
                            emailRedirectTo:
                                'io.supabase.flutterquickstart://login-callback/');

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Checa tu correo electrónico')));
                        }
                      } on AuthException catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(error.message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ));
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              const Text('Ocurrió un error. Intente de nuevo.'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ));
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
