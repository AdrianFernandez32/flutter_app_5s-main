// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class AdminAccessPage extends StatefulWidget {
//   const AdminAccessPage({Key? key}) : super(key: key);

//   @override
//   State<AdminAccessPage> createState() => _AdminAccessPageState();
// }

// class _AdminAccessPageState extends State<AdminAccessPage> {
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           const SizedBox(height: 150),
//           //Para hacer que el circulo este mas cerca del correo y contraseña
//           const CircleAvatar(
//             radius: 90,
//             backgroundColor: Colors.blueAccent,
//             backgroundImage: AssetImage('assets/profile_placeholder.png'),
//           ),
//           const SizedBox(height: 15),
//           // Texto de bienvenida se puede hacer mas grande si
//           const Text(
//             '¡Bienvenido!',
//             style: TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           // Más espacio entre el texto y los campos
//           const SizedBox(height: 20),
//           Expanded(
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextFormField(
//                       initialValue: "trasviña@santotomas.com",
//                       enabled: false,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.grey[300],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: true,
//                       decoration: InputDecoration(
//                         labelText: "Contraseña",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     SizedBox(
//                       width: 200,
//                       child: FilledButton(
//                         onPressed: () {
//                           context.go('/admin_dashboard');
//                           //Aqui tambien tenmos otro enlace, podriamos iniciar de ahi o poner otro enlace para movernos al acceso
//                         },
//                         style: FilledButton.styleFrom(
//                           minimumSize: const Size(double.infinity, 50),
//                           backgroundColor:
//                               const Color.fromARGB(255, 49, 136, 235),
//                         ),
//                         child: const Text(
//                           "Siguiente",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     // Enlace para recuperar contraseña, aun no tenemos el mockup para esta pestaña pero ahi esta el enlace
//                     TextButton(
//                       onPressed: () {
//                         context.go('/forgot_password');
//                       },
//                       child: const Text(
//                         "¿Olvidaste la contraseña?",
//                         style: TextStyle(color: Colors.blue, fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auth0_flutter/auth0_flutter.dart';

class AdminAccessPage extends StatefulWidget {
  const AdminAccessPage({Key? key}) : super(key: key);

  @override
  State<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends State<AdminAccessPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailValid = false;
  bool _emailVerified = false;

  @override
  void initState() {
    super.initState();
    // _emailController.text = "trasviña@santotomas.com";
    // _passwordController.text = "password123";
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailValid = false;
        _emailVerified = false;
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final validFormat = emailRegex.hasMatch(_emailController.text);

    setState(() {
      _emailValid = validFormat;
      _emailVerified = false;
    });

    if (!validFormat) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/auth/validate-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _emailVerified = data['isValid'] ?? false;
          if (!_emailVerified) {
            _errorMessage = 'Email no registrado en el sistema';
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Error verificando el email';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (!_emailVerified || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor complete todos los campos correctamente';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResponse = await http.post(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (authResponse.statusCode == 200) {
        final authData = json.decode(authResponse.body);
        final token = authData['token'];

        final adminCheck = await http.get(
          Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/admin/check'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (adminCheck.statusCode == 200) {
          if (mounted) {
            context.go('/admin_dashboard');
          }
        } else {
          setState(() {
            _errorMessage = 'No tienes permisos de administrador';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Credenciales incorrectas';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 70,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Acceso Administrativo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: _emailController.text.isNotEmpty
                          ? Icon(
                              _emailVerified ? Icons.check_circle : Icons.error,
                              color: _emailVerified
                                  ? Colors.green
                                  : _emailValid
                                      ? Colors.orange
                                      : Colors.red,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _emailValid = false;
                          _emailVerified = false;
                        });
                      } else {
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        setState(() {
                          _emailValid = emailRegex.hasMatch(value);
                          _emailVerified = false;
                        });
                      }
                    },
                    onEditingComplete: _validateEmail,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                  if (_emailController.text.isNotEmpty && !_emailValid)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Formato de email inválido',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "INGRESAR",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            context.go('/forgot_password');
                          },
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
