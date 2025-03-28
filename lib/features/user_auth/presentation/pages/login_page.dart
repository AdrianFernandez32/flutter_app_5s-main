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
                      const SizedBox(height: 30),
                      _buildEmailField(),
                      const SizedBox(height: 25),
                      _buildPasswordField(),
                      const SizedBox(height: 40),
                      _buildLoginButton(),
                      const SizedBox(height: 15),
                      _buildRegisterButton(),
                      const SizedBox(height: 10), // Espacio reducido
                      _buildAdminAccessDivider(), // Línea divisora
                      const SizedBox(height: 10), // Espacio reducido
                      _buildAdminAccessButton(), // Botón admin aquí
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

  Widget _buildEmailField() {
    return TextFormField(
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
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
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
    );
  }

  Widget _buildLoginButton() {
    return FilledButton(
      onPressed: _handleLogin,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        "Iniciar Sesión",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () => context.goNamed("Account"),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text("Registrarte"),
    );
  }

  Widget _buildAdminAccessDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[600],
            thickness: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Acceso especial",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[600],
            thickness: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminAccessButton() {
    return OutlinedButton.icon(
      onPressed: () => context.go('/inicio_admin'),
      icon: Icon(
        Icons.admin_panel_settings,
        color: Theme.of(context).primaryColor,
      ),
      label: Text(
        'Acceso Administrador',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final isValid = _formkey.currentState?.validate();
    if (isValid != true) return;

    context.goNamed("Menu");

    // try {
    //   final AuthResponse response = await client.auth.signInWithPassword(
    //     email: _emailController.text,
    //     password: _passwordController.text,
    //   );

    //   if (response.session != null) {
    //     context.goNamed('Menu');
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Error en el inicio de sesión'),
    //       backgroundColor: Colors.redAccent,
    //     ),
    //   );
    // }
  }
}
