import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_5s/main.dart';
import 'package:flutter_app_5s/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/user_basic_info.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  final backgroundColor = const Color.fromARGB(255, 255, 220, 193);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInitialProfile();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _getInitialProfile() async {
    final userID = supabase.auth.currentUser!.id;
    final data =
        await supabase.from('profiles').select().eq('id', userID).single();
    setState(() {
      _usernameController.text = data['username'];
      _passwordController.text = data['password'];
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromRGBO(252, 221, 198, 1),
        title: const Text(
          "Registro",
          style: TextStyle(color: Colors.black, fontSize: 32),
        ),
        leading: IconButton(
            onPressed: () {
              context.goNamed("SplashScreen");
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 33,
            )),
      ),
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
            child: Form(
              key: _formkey,
              child: SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    const SizedBox(
                      width: 250,
                      height: 75,
                      child: Text(
                        "Crear Cuenta",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in email address';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text('Correo'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill in password';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        label: Text(
                          'Contraseña (6 Caracteres o Más)',
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    FilledButton(
                      onPressed: () async {
                        final isValid = _formkey.currentState?.validate();
                        if (isValid != true) {
                          return;
                        }

                        try {
                          await client.auth.signUp(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Success, Confirm your account'),
                            backgroundColor: Colors.greenAccent,
                          ));
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Sign-Up failed'),
                            backgroundColor: Colors.redAccent,
                          ));
                        }
                      },
                      child: const Text('Registrarte'),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
