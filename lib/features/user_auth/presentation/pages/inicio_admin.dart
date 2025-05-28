import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InicioAdminPage extends StatelessWidget {
  const InicioAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // -----------------------------------------------
          // CONTENEDOR DEL LOGO (Totalmente independiente)
          // -----------------------------------------------
          Positioned(
            top: screenHeight * 0.12,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              alignment: Alignment.center,
              child: const Text(
                'Logo',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151946),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // -----------------------------------------------
          // CONTENEDOR DEL CONTENIDO (Totalmente independiente)
          // -----------------------------------------------
          Positioned(
            bottom: screenHeight * 0.15,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Comienza tu auditoría ahora.',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Con una poderosa herramienta podrás realizar auditorías en diferentes áreas.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 42),
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => context.go('/settings'),
                      //Ignoren esta ruta solo era para confirmar que esta eliminado las notificaciones
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 49, 136, 235),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Comenzar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
