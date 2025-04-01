import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final backgroundColor = const Color.fromARGB(255, 255, 255, 255);
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
      body: Container(
        color: backgroundColor,
        child: Center(
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 300),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 21, 25, 70),
                  ),
                ),
                const SizedBox(height: 150),
                _buildEmailField(),
                const SizedBox(height: 25),
                _buildPasswordField(),
                const SizedBox(height: 40),
                _buildLoginButton(),
                const SizedBox(height: 15),
                _buildUserAccessButton(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: "Correo Administrativo",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.admin_panel_settings),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "Contraseña",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock_outline),
      ),
    );
  }

  Widget _buildLoginButton() {
    return FilledButton(
      onPressed: () {
        context.go('/admin_dashboard');
      },
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color.fromARGB(255, 49, 136, 235),
      ),
      child: const Text(
        "Siguiente",
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUserAccessButton() {
    return TextButton(
      onPressed: () {
        context.go('/acceso_admin');
      },
      child: const Text.rich(
        TextSpan(
          text: '¿Ya tienes cuenta? ',
          style: TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: 'Inicia Sesión',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
