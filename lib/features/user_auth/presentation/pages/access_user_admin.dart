import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_5s/auth/auth_service.dart';

class AccessesPageUsuario extends StatefulWidget {
  final String userId;
  const AccessesPageUsuario({Key? key, required this.userId}) : super(key: key);

  @override
  AccessesPageUsuarioState createState() => AccessesPageUsuarioState();
}
class AccessesPageUsuarioState extends State<AccessesPageUsuario> {
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

  Future<void> _fetchUserData() async {
    setState(() { isLoading = true; });
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      if (accessToken == null) {
        setState(() { isLoading = false; });
        return;
      }
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/user-roles/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['name'] ?? '';
          userEmail = data['email'] ?? '';
          departments = (data['departments'] as List?)?.map((d) => {
            'name': d['department'] ?? '',
            'role': d['role'] ?? '',
          }).toList().cast<Map<String, String>>() ?? [];
          isLoading = false;
        });
      } else {
        setState(() { isLoading = false; });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
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
            context.goNamed('AccessesListPage');
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
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.black87),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String? selectedDepartment = dept['name'];
                                    String? selectedRole = dept['role'];
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
                                                  'Editar acceso',
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
                                                            // Aquí iría la lógica para editar el acceso
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
                                                            'Editar',
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
                                                            // Aquí iría la lógica para eliminar el acceso
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
                                                            'Eliminar',
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
                            ),
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