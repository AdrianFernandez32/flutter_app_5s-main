import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// To use it, just add it to the end of a Stack
// Recommend to use Stack in all of the Scaffolds to use this component correctly
class AdminNavBar extends StatelessWidget {
  const AdminNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      left: 20,
      right: 20,
      bottom: 32.0,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: colorScheme.secondary,
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
          selectedFontSize: 0,
          unselectedFontSize: 0,
          onTap: (index) => _handleNavigation(context, index),
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
                    child:
                        Icon(Icons.add_circle, size: 40, color: Colors.white)),
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
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('AdminDashboard');
        break;
      case 1:
        context.goNamed('AccessesListPage');
        break;
      case 2:
        context.goNamed('CreateOrganization');
        break;
      case 3:
        context.goNamed('AreaMenu');
        break;
      case 4:
        context.goNamed('Calificar 5s');
        break;
    }
  }
}
