import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        toolbarHeight: 10, // Added to reduce the height of the AppBar
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.zero, // Ensure no extra padding
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://phantom-marca-us.uecdn.es/67214b3666019836c0f2b41c2c48c1b3/resize/828/f/jpg/assets/multimedia/imagenes/2025/03/04/17410644450708.jpg'),
                            radius: 30,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Carlos Trasviña',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildMenuItem(context, Icons.business, 'Crear nueva org',
                        'CreateOrganization'),
                    _buildMenuItem(context, Icons.group, 'Áreas', 'AreaMenu',
                        onTap: () {
                      final idProvider =
                          Provider.of<AdminIdProvider>(context, listen: false);
                      if (idProvider.orgId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Por favor, selecciona una organización primero'),
                          ),
                        );
                        return;
                      }
                      context.goNamed('AreaMenu');
                    }),
                    _buildMenuItem(
                        context, Icons.person, 'Accesos', 'AccessesListPage'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32.0,
            child: Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedFontSize:
                    0, // Para evitar espacio adicional por el texto
                unselectedFontSize: 0,
                items: const [
                  BottomNavigationBarItem(
                      icon: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.home, color: Colors.white)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.person, color: Colors.white)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.add_circle,
                              size: 40, color: Colors.white)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.article, color: Colors.white)),
                      label: ''),
                  BottomNavigationBarItem(
                      icon: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.pie_chart, color: Colors.white)),
                      label: ''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, String route,
      {VoidCallback? onTap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
        onTap: onTap ?? () => context.goNamed(route),
      ),
    );
  }
}
