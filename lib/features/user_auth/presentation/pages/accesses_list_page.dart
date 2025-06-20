import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class AccessesListPage extends StatefulWidget {
  const AccessesListPage({Key? key}) : super(key: key);

  @override
  State<AccessesListPage> createState() => _AccessesListPageState();
}

class _AccessesListPageState extends State<AccessesListPage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  bool isAZ = false;
  Map<String, List<Map<String, String>>> userRoles = {};

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUserRoles(String userId) async {
    final authService = AuthService();
    final accessToken = authService.accessToken;
    if (accessToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/user-roles/$userId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final departments = (data['departments'] as List?)?.map((d) => {
          'name': d['department'] ?? '',
          'role': d['role'] ?? '',
        }).toList().cast<Map<String, String>>() ?? [];
        setState(() {
          userRoles[userId] = departments;
        });
      }
    } catch (e) {
      // Ignorar errores individuales
    }
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      final orgId = authService.organizationId;
      if (accessToken == null || orgId == null) {
        setState(() {
          error = 'No hay organización seleccionada o sesión expirada.';
          isLoading = false;
        });
        return;
      }
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          users = data is List ? data : [];
          filteredUsers = users;
          isLoading = false;
        });
        // Llama a fetchUserRoles para cada usuario
        for (final user in users) {
          final userId = user['id']?.toString();
          if (userId != null) {
            fetchUserRoles(userId);
          }
        }
      } else {
        setState(() {
          error = 'Error: \\${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de red: $e';
        isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      searchQuery = query;
      filteredUsers = users.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      if (isAZ) {
        filteredUsers.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
      }
    });
  }

  void _sortAZ() {
    setState(() {
      isAZ = !isAZ;
      filteredUsers.sort((a, b) {
        final nameA = (a['name'] ?? '').toString();
        final nameB = (b['name'] ?? '').toString();
        return isAZ ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      });
    });
  }

  Future<String?> _getInvitationCode() async {
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      final orgId = authService.organizationId;
      if (accessToken == null || orgId == null) {
        return null;
      }
      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/generate-code/$orgId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        return response.body.trim();
      }
      return null;
    } catch (e) {
      print('Error getting invitation code: $e');
      return null;
    }
  }

  void _showInvitationCodeDialog(BuildContext context) async {
    final code = await _getInvitationCode();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código de Invitación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Comparte este código con los usuarios que quieras invitar:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code ?? 'Error al generar código',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      if (code != null) {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código copiado al portapapeles'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed('Menu'),
        ),
        title: const Text('Accesos', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Buscar',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: _filterUsers,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sort buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_drop_down),
                            label: const Text('Ordenar por'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _sortAZ,
                            icon: const Icon(Icons.arrow_upward),
                            label: const Text('A-Z'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAZ ? colorScheme.secondary : Colors.white,
                              foregroundColor: isAZ ? Colors.white : Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // User list
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                final userId = user['id']?.toString();
                                if (userId != null) {
                                  context.goNamed('Gestion de Acceso Usuario', pathParameters: {'userId': userId});
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundImage: user['image'] != null
                                              ? AssetImage(user['image']!)
                                              : const AssetImage('lib/assets/images/perfil_fake.jpg') as ImageProvider,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            user['name'] ?? 'Sin nombre',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Color(0xFF223A53),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (userRoles[user['id']?.toString()] != null)
                                      ...userRoles[user['id']?.toString()]!.map((dept) => Padding(
                                            padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                            child: Card(
                                              color: const Color(0xFFE9EEF1),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: ListTile(
                                                dense: true,
                                                title: Center(
                                                  child: Text(
                                                    dept['name']!,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
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
                                              ),
                                            ),
                                          )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: SizedBox(
        width: 160,
        height: 60,
        child: FloatingActionButton.extended(
          onPressed: () => _showInvitationCodeDialog(context),
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          icon: const Icon(Icons.add, size: 28),
          label: const Text('Invitar', style: TextStyle(fontSize: 18)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
} 