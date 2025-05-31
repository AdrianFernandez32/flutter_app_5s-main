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
import 'package:auth0_flutter/auth0_flutter.dart';

final auth0 = Auth0(
  'dev-hjpyk5n4wwo7vblz.us.auth0.com',
  'VfUwLTwEos9u7shjDHnyna9d1BEadiaG', // reemplaza con tu clientId
);

class AuthService {
  String? accessToken;
  String? idToken;
  UserProfile? user;
}

final authService = AuthService();

class AdminAccessPage extends StatefulWidget {
  const AdminAccessPage({Key? key}) : super(key: key);

  @override
  State<AdminAccessPage> createState() => _AdminAccessPageState();
}

class _AdminAccessPageState extends State<AdminAccessPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await auth0
          .webAuthentication(scheme: 'com.example.flutterapp5s')
          .login(
            audience: 'https://dev-aodesvgtpd08tn2z.us.auth0.com/api/v2/',
          );

      authService.accessToken = result.accessToken;
      authService.idToken = result.idToken;
      authService.user = result.user;

      // Aquí podrías hacer la llamada a backend para validar roles o permisos

      if (mounted) {
        context.goNamed(
            'OrganizationsListPage'); // O la ruta que tengas para el dashboard
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de login: $e';
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _login,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color.fromARGB(255, 49, 136, 235),
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
                          "Acceder",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),
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
      ),
    );
  }
}
