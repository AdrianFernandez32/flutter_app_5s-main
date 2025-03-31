import 'package:flutter/material.dart';

class CreateOrganizationPage extends StatelessWidget {
  const CreateOrganizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Organization")),
      body: const Center(child: Text("This is the create organization page")),
    );
  }
}
