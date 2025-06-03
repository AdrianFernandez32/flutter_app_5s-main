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
  List<Map<String, dynamic>> departments = [];
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;
      final orgId = authService.organizationId;
      if (accessToken == null || orgId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Primero obtenemos los datos del usuario
      final usersResponse = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (usersResponse.statusCode == 200) {
        final usersData = jsonDecode(usersResponse.body) as List;
        // Encontramos el usuario específico
        userData = usersData.firstWhere(
          (user) => user['id'] == widget.userId,
          orElse: () => null,
        );

        if (userData != null) {
          setState(() {
            userName = userData!['name'] ?? 'Sin nombre';
            userEmail = userData!['email'] ?? 'Sin email';
          });
        }
      }

      // Luego obtenemos los roles del usuario
      final rolesResponse = await http.get(
        Uri.parse(
            'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users/${widget.userId}/roles'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (rolesResponse.statusCode == 200) {
        final data = jsonDecode(rolesResponse.body);
        setState(() {
          departments = (data as List?)
                  ?.map((d) => {
                        'id': d['id']?.toString(),
                        'name': d['roleName'] ?? '',
                        'role': d['roleName'] ?? '',
                        'roleId': d['roleId']?.toString(),
                        'allowedSubareaId': d['allowedSubareaId']?.toString(),
                        'allowedSubareaName': d['allowedSubareaName'] ?? '',
                        'areaId': d['areaId']?.toString(),
                        'areaName': d['areaName'] ?? '',
                      })
                  .toList() ??
              [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
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
                  // Profile Avatar with blue border
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colorScheme.secondary, width: 6),
                      ),
                      child: const CircleAvatar(
                        radius: 64,
                        backgroundColor: Color(0xFFEDEDED),
                        backgroundImage:
                            AssetImage('lib/assets/images/perfil_fake.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User name
                  Text(
                    userName.isNotEmpty ? userName : 'Sin nombre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0, bottom: 16.0),
                    child: Text(
                      userEmail.isNotEmpty ? userEmail : 'Sin email',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (departments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 12),
                        child: const Center(
                          child: Text(
                            'Este usuario no tiene permisos asignados',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...departments.map((dept) => Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 16.0),
                          child: Card(
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              title: Center(
                                child: Text(
                                  dept['name']?.isNotEmpty == true
                                      ? dept['name']!
                                      : 'Sin departamento',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              subtitle: Column(
                                children: [
                                  Text(
                                    'Rol: ${dept['role']?.isNotEmpty == true ? dept['role']! : 'Sin rol'}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (dept['areaName']?.isNotEmpty == true)
                                    Text(
                                      'Área: ${dept['areaName']}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  if (dept['allowedSubareaName']?.isNotEmpty ==
                                      true)
                                    Text(
                                      'Subárea: ${dept['allowedSubareaName']}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit,
                                    size: 20, color: Colors.black87),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      // Inicializar variables SIEMPRE que se abre el modal
                                      int? selectedRoleId =
                                          int.tryParse(dept['roleId'] ?? '');
                                      int? userRoleId =
                                          int.tryParse(dept['id'] ?? '');
                                      int? currentSubareaId = int.tryParse(
                                          dept['allowedSubareaId'] ?? '');
                                      int? areaId =
                                          int.tryParse(dept['areaId'] ?? '');
                                      String areaName =
                                          dept['areaName'] ?? 'Área';
                                      int? selectedSubareaId = currentSubareaId;
                                      List<Map<String, dynamic>> subareas = [];
                                      bool loadingSubareas = true;
                                      bool loadingRoles = true;
                                      Map<String, dynamic>? currentRole;

                                      final authService = AuthService();
                                      final orgId = authService.organizationId;

                                      // Fetch subareas for the area
                                      Future<void> fetchSubareas(
                                          int areaId) async {
                                        if (orgId == null) return;
                                        loadingSubareas = true;
                                        subareas = [];
                                        try {
                                          final response = await http.get(
                                            Uri.parse(
                                                'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area/$areaId/subarea'),
                                            headers: {
                                              'Authorization':
                                                  'Bearer ${authService.accessToken}',
                                            },
                                          );
                                          if (response.statusCode == 200) {
                                            final data =
                                                jsonDecode(response.body);
                                            subareas = (data as List)
                                                .map((s) => {
                                                      'id': s['id'],
                                                      'name': s['name'],
                                                    })
                                                .toList();

                                            // Si no hay subárea seleccionada, seleccionar la primera
                                            if (selectedSubareaId == null &&
                                                subareas.isNotEmpty) {
                                              selectedSubareaId =
                                                  subareas.first['id'] as int?;
                                            }
                                          }
                                        } catch (e) {
                                          print(
                                              'Debug - error fetching subareas: $e');
                                        }
                                        loadingSubareas = false;
                                      }

                                      // Fetch all roles for the organization
                                      Future<void> fetchRoles() async {
                                        if (orgId == null) return;
                                        loadingRoles = true;
                                        try {
                                          final response = await http.get(
                                            Uri.parse(
                                                'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users/${widget.userId}/roles'),
                                            headers: {
                                              'Authorization':
                                                  'Bearer ${authService.accessToken}',
                                            },
                                          );
                                          if (response.statusCode == 200) {
                                            final data =
                                                jsonDecode(response.body)
                                                    as List;
                                            print('Debug - dept: $dept');
                                            print('Debug - roles data: $data');

                                            // Find the specific role we're editing by matching roleName and roleId
                                            currentRole = data.firstWhere(
                                              (role) {
                                                final roleName =
                                                    role['roleName']
                                                        ?.toString()
                                                        .toLowerCase();
                                                final roleId = role['roleId'];
                                                print(
                                                    'Debug - comparing roleName: $roleName with dept role: ${dept['role']?.toString().toLowerCase()}');
                                                print(
                                                    'Debug - comparing roleId: $roleId with selectedRoleId: $selectedRoleId');
                                                return roleName ==
                                                        dept['role']
                                                            ?.toString()
                                                            .toLowerCase() &&
                                                    roleId == selectedRoleId;
                                              },
                                              orElse: () => null,
                                            );

                                            print(
                                                'Debug - found role: $currentRole');

                                            if (currentRole != null) {
                                              // Update the UI with the found role data
                                              userRoleId = currentRole!['id'];
                                              selectedRoleId =
                                                  currentRole!['roleId'];
                                              selectedSubareaId = currentRole![
                                                  'allowedSubareaId'];
                                              areaId = currentRole!['areaId'];

                                              // Obtener el nombre del área
                                              try {
                                                final areaResponse =
                                                    await http.get(
                                                  Uri.parse(
                                                      'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area/$areaId'),
                                                  headers: {
                                                    'Authorization':
                                                        'Bearer ${authService.accessToken}',
                                                  },
                                                );
                                                if (areaResponse.statusCode ==
                                                    200) {
                                                  final areaData = jsonDecode(
                                                      areaResponse.body);
                                                  areaName = areaData['name'] ??
                                                      'Área';
                                                }
                                              } catch (e) {
                                                print(
                                                    'Debug - error fetching area: $e');
                                              }

                                              // Obtener las subáreas para el área actual
                                              if (areaId != null) {
                                                await fetchSubareas(areaId!);
                                              }

                                              setState(
                                                  () {}); // Actualizar el UI con los nuevos datos
                                            }
                                          }
                                        } catch (e) {
                                          print(
                                              'Debug - error fetching roles: $e');
                                        }
                                        loadingRoles = false;
                                      }

                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          // Siempre que se abre el modal, hacer fetch de roles y subáreas
                                          if (loadingRoles) {
                                            fetchRoles().then((_) {
                                              final currentAreaId = areaId;
                                              if (currentAreaId != null) {
                                                fetchSubareas(currentAreaId)
                                                    .then(
                                                        (_) => setState(() {}));
                                              }
                                              setState(() {});
                                            });
                                          }
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 24),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  top: 60),
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 40, 20, 24),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(28),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.08),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Editar acceso',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    if (loadingRoles)
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator())
                                                    else if (currentRole ==
                                                        null)
                                                      const Center(
                                                        child: Text(
                                                          'No se encontró el rol',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      )
                                                    else ...[
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Área',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12,
                                                                horizontal: 16),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Text(
                                                          areaName,
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 18),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Rol',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade400,
                                                              width: 1.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              int>(
                                                            isExpanded: true,
                                                            value:
                                                                selectedRoleId,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12),
                                                              child: Text(
                                                                'Selecciona un rol',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ),
                                                            icon: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right: 8),
                                                              child: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down_rounded,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 32),
                                                            ),
                                                            items: const [
                                                              DropdownMenuItem(
                                                                value: 2,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              12),
                                                                  child: Text(
                                                                      'Auditor',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18)),
                                                                ),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 3,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              12),
                                                                  child: Text(
                                                                      'Editor',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              18)),
                                                                ),
                                                              ),
                                                            ],
                                                            onChanged: (value) {
                                                              setState(() =>
                                                                  selectedRoleId =
                                                                      value);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 18),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Subárea',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .blueAccent,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade400,
                                                              width: 1.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                              int>(
                                                            isExpanded: true,
                                                            value:
                                                                selectedSubareaId,
                                                            hint: const Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          12),
                                                              child: Text(
                                                                'Selecciona una subárea',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ),
                                                            icon: const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right: 8),
                                                              child: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down_rounded,
                                                                  color: Colors
                                                                      .blue,
                                                                  size: 32),
                                                            ),
                                                            items: subareas
                                                                .map((sub) =>
                                                                    DropdownMenuItem(
                                                                      value: sub[
                                                                              'id']
                                                                          as int?,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                12),
                                                                        child: Text(
                                                                            sub['name'] ??
                                                                                '',
                                                                            style:
                                                                                const TextStyle(fontSize: 18)),
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                            onChanged: (value) {
                                                              setState(() =>
                                                                  selectedSubareaId =
                                                                      value);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 28),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  final accessToken =
                                                                      authService
                                                                          .accessToken;
                                                                  if (selectedRoleId == null ||
                                                                      selectedSubareaId ==
                                                                          null ||
                                                                      orgId ==
                                                                          null ||
                                                                      userRoleId ==
                                                                          null) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text('Completa todos los campos.')),
                                                                    );
                                                                    return;
                                                                  }
                                                                  final body = {
                                                                    'roleId':
                                                                        selectedRoleId,
                                                                    'allowedSubareaId':
                                                                        selectedSubareaId,
                                                                  };
                                                                  print('PUT body: ' +
                                                                      body.toString());
                                                                  try {
                                                                    final response =
                                                                        await http
                                                                            .put(
                                                                      Uri.parse(
                                                                          'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users/${widget.userId}/roles/$userRoleId'),
                                                                      headers: {
                                                                        'Authorization':
                                                                            'Bearer $accessToken',
                                                                        'Content-Type':
                                                                            'application/json',
                                                                      },
                                                                      body: jsonEncode(
                                                                          body),
                                                                    );
                                                                    if (response.statusCode ==
                                                                            200 ||
                                                                        response.statusCode ==
                                                                            201) {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      await _fetchUserData();
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                            content:
                                                                                Text('Rol editado correctamente.')),
                                                                      );
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text('Error al editar rol: \\${response.statusCode}')),
                                                                      );
                                                                    }
                                                                  } catch (e) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text('Error de red: $e')),
                                                                    );
                                                                  }
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18),
                                                                  ),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'Editar',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18),
                                                                  ),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'Cancelar',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8),
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  final confirmed =
                                                                      await showDialog<
                                                                          bool>(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) =>
                                                                            AlertDialog(
                                                                      title: const Text(
                                                                          'Confirmar eliminación'),
                                                                      content:
                                                                          const Text(
                                                                              '¿Estás seguro de que deseas eliminar este rol? Esta acción no se puede deshacer.'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.of(context).pop(false),
                                                                          child:
                                                                              const Text('Cancelar'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () =>
                                                                              Navigator.of(context).pop(true),
                                                                          child: const Text(
                                                                              'Eliminar',
                                                                              style: TextStyle(color: Colors.red)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                  if (confirmed ==
                                                                      true) {
                                                                    final accessToken =
                                                                        authService
                                                                            .accessToken;
                                                                    if (orgId ==
                                                                            null ||
                                                                        userRoleId ==
                                                                            null) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        const SnackBar(
                                                                            content:
                                                                                Text('Faltan datos para eliminar.')),
                                                                      );
                                                                      return;
                                                                    }
                                                                    try {
                                                                      final response =
                                                                          await http
                                                                              .delete(
                                                                        Uri.parse(
                                                                            'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users/${widget.userId}/roles/$userRoleId'),
                                                                        headers: {
                                                                          'Authorization':
                                                                              'Bearer $accessToken',
                                                                        },
                                                                      );
                                                                      if (response.statusCode ==
                                                                              200 ||
                                                                          response.statusCode ==
                                                                              204) {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        await _fetchUserData();
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text('Rol eliminado correctamente.')),
                                                                        );
                                                                      } else {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          SnackBar(
                                                                              content: Text('Error al eliminar rol: \\${response.statusCode}')),
                                                                        );
                                                                      }
                                                                    } catch (e) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text('Error de red: $e')),
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            18),
                                                                  ),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          12),
                                                                ),
                                                                child:
                                                                    const Text(
                                                                  'Eliminar',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ],
                                                ),
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
              int? selectedRoleId;
              int? selectedAreaId;
              int? selectedSubareaId;
              List<Map<String, dynamic>> areas = [];
              List<Map<String, dynamic>> subareas = [];
              bool loadingAreas = true;
              bool loadingSubareas = false;

              final authService = AuthService();
              final orgId = authService.organizationId;

              // Fetch areas when modal opens
              Future<void> fetchAreas() async {
                if (orgId == null) return;
                try {
                  final response = await http.get(
                    Uri.parse(
                        'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area'),
                    headers: {
                      'Authorization': 'Bearer ${authService.accessToken}',
                    },
                  );
                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    areas = (data as List)
                        .map((a) => {
                              'id': a['id'],
                              'name': a['name'],
                            })
                        .toList();
                  }
                } catch (_) {}
                loadingAreas = false;
              }

              // Fetch subareas when area is selected
              Future<void> fetchSubareas(int areaId) async {
                if (orgId == null) return;
                loadingSubareas = true;
                subareas = [];
                try {
                  final response = await http.get(
                    Uri.parse(
                        'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/area/$areaId/subarea'),
                    headers: {
                      'Authorization': 'Bearer ${authService.accessToken}',
                    },
                  );
                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    subareas = (data as List)
                        .map((s) => {
                              'id': s['id'],
                              'name': s['name'],
                            })
                        .toList();
                  }
                } catch (_) {}
                loadingSubareas = false;
              }

              return StatefulBuilder(
                builder: (context, setState) {
                  // Fetch areas only once
                  if (loadingAreas) {
                    fetchAreas().then((_) => setState(() {}));
                  }
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 24),
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
                      child: SingleChildScrollView(
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
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedRoleId,
                                  hint: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
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
                                    child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.blue,
                                        size: 32),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text('Auditor',
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 3,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text('Editor',
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() => selectedRoleId = value);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Área',
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
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedAreaId,
                                  hint: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Selecciona un área',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.blue,
                                        size: 32),
                                  ),
                                  items: areas
                                      .map((area) => DropdownMenuItem(
                                            value: area['id'] as int?,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Text(area['name'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 18)),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAreaId = value;
                                      selectedSubareaId = null;
                                      loadingSubareas = true;
                                    });
                                    if (value != null) {
                                      fetchSubareas(value)
                                          .then((_) => setState(() {}));
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Subárea',
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
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 1.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: selectedSubareaId,
                                  hint: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Selecciona una subárea',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.blue,
                                        size: 32),
                                  ),
                                  items: subareas
                                      .map((sub) => DropdownMenuItem(
                                            value: sub['id'] as int?,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Text(sub['name'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 18)),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => selectedSubareaId = value);
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final accessToken =
                                            authService.accessToken;
                                        if (selectedRoleId == null ||
                                            selectedAreaId == null ||
                                            selectedSubareaId == null ||
                                            accessToken == null ||
                                            orgId == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Completa todos los campos.')),
                                          );
                                          return;
                                        }
                                        final body = {
                                          'roleId': selectedRoleId,
                                          'allowedSubareaId': selectedSubareaId,
                                        };
                                        print('POST body: ' + body.toString());
                                        try {
                                          final response = await http.post(
                                            Uri.parse(
                                                'https://djnxv2fqbiqog.cloudfront.net/org/$orgId/users/${widget.userId}/roles'),
                                            headers: {
                                              'Authorization':
                                                  'Bearer $accessToken',
                                              'Content-Type':
                                                  'application/json',
                                            },
                                            body: jsonEncode(body),
                                          );
                                          if (response.statusCode == 200 ||
                                              response.statusCode == 201) {
                                            Navigator.of(context).pop();
                                            await _fetchUserData();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Rol agregado correctamente.')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error al agregar rol: \\${response.statusCode}')),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Error de red: $e')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: const Text(
                                        'Registrar',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
