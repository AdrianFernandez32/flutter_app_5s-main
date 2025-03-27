import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/app/splash_screen/splash_screen.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/acceso_admin.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/account_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/admin_login_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/areas_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/audit_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/audits_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/grading_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/main_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/manage_areas_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/manage_questionnaries_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/manage_users_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/questionnaire_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/settings_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/signin_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/statistics_audit_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/zones_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/create_questionnarie_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/themeProvider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import "package:provider/provider.dart";

void main() async {
  // await Supabase.initialize(
  //   url: 'https://rzbqldwiqhcxgjoufrzs.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6YnFsZHdpcWhjeGdqb3VmcnpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTAzNzI1NDIsImV4cCI6MjAyNTk0ODU0Mn0.2vSOwP4wBIv5lwztvsCkr97iyjw9dS0l-BCH0ndbyGI',
  // );
  //  Change Notifier Provider for the theme changes
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

final supabase = Supabase.instance.client;

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'SplashScreen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'Login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/admin_login',
      name: 'AdminLogin',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      path: '/acceso_admin',
      name: 'AdminAccessPage',
      builder: (context, state) => const AdminAccessPage(),
    ),
    GoRoute(
      path: '/signin',
      name: 'Signin',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/account',
      name: 'Account',
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: '/menu',
      name: 'Menu',
      builder: (context, state) => const MainMenu(),
    ),
    GoRoute(
      path: '/auditar',
      name: 'Auditar',
      builder: (context, state) => const AuditPage(),
    ),
    GoRoute(
      path: '/auditorias/:zona/:auditDate/:area',
      name: 'Auditorias',
      builder: (context, state) {
        final zona = state.pathParameters['zona']!;
        final area = state.pathParameters['area']!;
        final auditDate = state.pathParameters['auditDate']!;
        final color = state.extra as Color? ?? Colors.red;
        return StatisticsAuditPage(
          zona: zona,
          auditDate: auditDate,
          area: area,
          color: color,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'Settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/gestionareas',
      name: 'Gestion de Areas',
      builder: (context, state) => const AreasPage(),
    ),
    GoRoute(
      path: '/editarareas',
      name: 'Editar Areas',
      builder: (context, state) => const ManageAreasPage(),
    ),
    GoRoute(
      path: '/calificar5s',
      name: 'Calificar 5s',
      builder: (context, state) => const GradingPage(),
    ),
    GoRoute(
      path: '/zonesPage',
      name: 'Zones Page',
      builder: (context, state) => const ZonesPage(),
    ),
    GoRoute(
      path: '/auditsPage/:zone/:area',
      name: 'Audits Page',
      builder: (context, state) {
        final zone = state.pathParameters['zone']!;
        final area = state.pathParameters['area']!;

        final color = state.extra as Color? ?? Colors.black;
        return AuditsPage(
          zone: zone,
          color: color,
          area: area,
        );
      },
    ),
    GoRoute(
      path: '/cuestionario',
      name: 'Cuestionario',
      builder: (context, state) => const QuestionnairePage(),
    ),
    GoRoute(
      path: '/gestioncuestionarios',
      name: 'Gestion de Cuestionarios',
      builder: (context, state) => const ManageQuestionnariesPage(),
    ),
    GoRoute(
      path: '/gestionusuarios',
      name: 'Gestion de Usuarios',
      builder: (context, state) => const ManageUsersPage(),
    ),
    GoRoute(
      name: 'CreateQuestionnairePage',
      path: '/create_questionnaire',
      builder: (context, state) => const CreateQuestionnairePage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: '5s Flutter App',
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: themeProvider.colors.primary,
              secondary: themeProvider.colors.secondary,
              surface: themeProvider.colors.background,
            ),
            scaffoldBackgroundColor: themeProvider.colors.background,
            appBarTheme: AppBarTheme(
              backgroundColor: themeProvider.colors.primary,
              foregroundColor: _getContrastColor(themeProvider.colors.primary),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: themeProvider.colors.accent,
            ),
            useMaterial3: true,
          ),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
