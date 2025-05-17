import 'package:flutter/material.dart';
import '../widgets/departmentItem.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/accesses_page.dart';

class AccessesPageUsuario extends StatefulWidget {
  const AccessesPageUsuario({Key? key}) : super(key: key);

  @override
  AccesesPageUsuarioState createState() => AccesesPageUsuarioState();
}
class AccesesPageUsuarioState extends State<AccessesPageUsuario> {
  // State variables for user and departments
  String userName = '';
  String userEmail = '';
  List<Map<String, String>> departments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Simulate fetching data from an API
  Future<void> _fetchUserData() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    setState(() {
      userName = 'Santiago Pérez';
      userEmail = 'santiago.perez@cetys.edu.mx';
      departments = [
        {'name': 'Departamento A', 'role': 'Auditor'},
        {'name': 'Departamento B', 'role': 'Auditor'},
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () {
            context.goNamed('Gestion de Accesos');
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 24),
                  // Smaller Profile Avatar with blue border
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 5),
                      ),
                      child: const CircleAvatar(
                        radius: 54,
                        backgroundColor: Color(0xFFEDEDED),
                        backgroundImage: AssetImage('lib/assets/images/perfil_fake.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Smaller User name
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 16.0),
                    child: Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  ...departments.map((dept) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Card(
                          color: const Color(0xFFE9EEF1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            title: Center(
                              child: Text(
                                dept['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            subtitle: Center(
                              child: Text(
                                'Rol: ${dept['role']!}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            trailing: const Icon(Icons.edit, size: 20, color: Colors.black87),
                            onTap: () {},
                          ),
                        ),
                      )),
                  const Spacer(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              String? selectedDepartment;
              String? selectedRole;
              final List<String> departmentOptions = departments.map((d) => d['name']!).toList();
              final List<String> roleOptions = ['Viewer', 'Auditor', 'Admin'];
              return StatefulBuilder(
                builder: (context, setState) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                    child: Container(
                      margin: const EdgeInsets.only(top: 60),
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Nuevo acceso',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Departamento',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 1.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedDepartment,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Selecciona un departamento',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                icon: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue, size: 32),
                                ),
                                items: departmentOptions.map((dep) => DropdownMenuItem(
                                  value: dep,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      dep,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() => selectedDepartment = value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Rol',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400, width: 1.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedRole,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Selecciona un rol',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                icon: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue, size: 32),
                                ),
                                items: roleOptions.map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      role,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() => selectedRole = value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Aquí iría la lógica para registrar el acceso
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Registrar',
                                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}