import 'package:flutter/material.dart';

class OrgItem extends StatelessWidget {
  final Map<String, dynamic> org;
  final VoidCallback onTap;

  const OrgItem({super.key, required this.org, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(org['logoUrl']),
      ),
      title: Text(org['name']),
      subtitle: Text(org['description']),
      onTap: onTap,
    );
  }
}
