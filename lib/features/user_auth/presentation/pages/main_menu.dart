import 'package:flutter/material.dart';
// Removed unused import
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_5s/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainMenu extends StatefulWidget {
  const MainMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final authService = AuthService();
      final accessToken = authService.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token available');
      }

      final response = await http.get(
        Uri.parse('https://djnxv2fqbiqog.cloudfront.net/user/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('USER PROFILE RESPONSE:');
        print(decoded);
        setState(() {
          _userProfile = decoded;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        elevation: 0,
        toolbarHeight: 0,
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
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: _userProfile?['picture'] != null
                                ? NetworkImage(_userProfile!['picture'])
                                : const NetworkImage(
                                    'https://phantom-marca-us.uecdn.es/67214b3666019836c0f2b41c2c48c1b3/resize/828/f/jpg/assets/multimedia/imagenes/2025/03/04/17410644450708.jpg'),
                            radius: 30,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                _userProfile?['name'] ?? 'Usuario',
                                style: const TextStyle(
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
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 40, 16.0, 16.0),
                child: const Column(
                  children: [
                    _Button(
                      title: 'Auditar',
                      icon: Icons.library_add_check_outlined,
                      goToNamed: 'Auditar',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _Button(
                      title: 'Auditorías',
                      icon: Icons.file_copy_outlined,
                      goToNamed: 'Zones Page',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _Button(
                      title: 'Áreas',
                      icon: Icons.grid_view_outlined,
                      goToNamed: 'Gestion de Areas',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _Button(
                      title: 'Ajustes',
                      icon: Icons.settings_outlined,
                      goToNamed: 'Settings',
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 60,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String title;
  final IconData icon;
  final String goToNamed;

  const _Button({
    Key? key,
    required this.title,
    required this.icon,
    required this.goToNamed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed(goToNamed);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 17,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey, // Use black87 for a deeper black
            width: 1, // Adjust thickness
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 70,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
