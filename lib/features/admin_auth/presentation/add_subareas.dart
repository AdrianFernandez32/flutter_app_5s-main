import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart'
    show AdminAppBar;
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/subarea_item.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:flutter_app_5s/utils/global_states/id_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddSubArea extends StatefulWidget {
  const AddSubArea({super.key});

  @override
  State<AddSubArea> createState() => _AddSubAreaState();
}

class _AddSubAreaState extends State<AddSubArea> {
  List<Map<String, dynamic>> subAreas = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idProvider = Provider.of<IdProvider>(context, listen: false);
      if (idProvider.orgId == null || idProvider.areaId == null) {
        context.goNamed('OrgMenu');
      }
    });
    _fetchSubAreas();
  }

  Future<void> _fetchSubAreas() async {
    final idProvider = Provider.of<IdProvider>(context, listen: false);
    final orgId = idProvider.orgId;
    final areaId = idProvider.areaId;

    if (orgId == null || areaId == null) {
      setState(() {
        errorMessage = 'Faltan IDs necesarios';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['API_URL']}/org/$orgId/area'),
          headers: {'Authorization': 'Bearer ...'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          subAreas = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'title': item['name'],
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Error al cargar departamentos: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AdminAppBar(
        title: "Departamentos",
        onBackPressed: () {
          IdProvider().clearAreaId();
          context.pushNamed(
            'AdminDashboard',
          );
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Container(
                color: colorScheme.surface,
                child: ListView(
                  children: [
                    ...subAreas
                        .map((department) => SubAreaItem(
                              title: department['title'],
                              onTap: () => _handleSubAreaTap(department['id']),
                            ))
                        .toList(),
                  ],
                )),
          ),
          const AdminNavBar(),
          FloatingPlusActionButton(
            onPressed: () {
              //TODO : Agregar funcionalidad
              print("AddDepartment");
            },
          )
        ],
      ),
    );
  }

  void _handleSubAreaTap(String id) {
    final idProvider = Provider.of<IdProvider>(context, listen: false);
    idProvider.setSubareaId(id);
    context.pushNamed('FiveSMenu');
  }
}
