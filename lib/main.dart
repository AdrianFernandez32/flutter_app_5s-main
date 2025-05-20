import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/admin_auth/presentation/add_subareas.dart';
import 'package:flutter_app_5s/features/admin_auth/presentation/areas/areas.dart';
import 'package:flutter_app_5s/features/admin_auth/presentation/questionnaires_admin_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/acceso_admin.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/areas_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/audit_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/audits_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/create_organization_page.dart';
import 'package:flutter_app_5s/features/admin_auth/presentation/five_s_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/grading_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/inicio_admin.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/main_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/questionnaire_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/settings_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/statistics_audit_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/zones_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/access_user_admin.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/themeProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import "package:provider/provider.dart";
import 'package:flutter_app_5s/features/user_auth/presentation/pages/accesses_list_page.dart';

void main() async {
  // await Supabase.initialize(
  //   url: 'https://rzbqldwiqhcxgjoufrzs.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6YnFsZHdpcWhjeGdqb3VmcnpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTAzNzI1NDIsImV4cCI6MjAyNTk0ODU0Mn0.2vSOwP4wBIv5lwztvsCkr97iyjw9dS0l-BCH0ndbyGI',
  // );
  //  Change Notifier Provider for the theme changes
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

final supabase = Supabase.instance.client;

final GoRouter _router = GoRouter(
  initialLocation: '/inicio_admin',
  routes: [
    GoRoute(
      path: '/acceso_admin',
      name: 'AdminAccessPage',
      builder: (context, state) => const AdminAccessPage(),
    ),
    GoRoute(
      path: '/inicio_admin',
      name: 'InicioAdmin',
      builder: (context, state) => const InicioAdminPage(),
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
      path: '/create-organization',
      name: 'CreateOrganization',
      builder: (context, state) => const CreateOrganizationPage(),
    ),
    GoRoute(
      path: '/auditsPage/:subareaId/:subareaName',
      name: 'Audits Page',
      builder: (context, state) {
        final subareaId =
            int.tryParse(state.pathParameters['subareaId'] ?? '') ?? 0;
        final subareaName = state.pathParameters['subareaName'] ?? '';
        final color = state.extra as Color? ?? Colors.black;
        return AuditsPage(
          subareaId: subareaId,
          subareaName: subareaName,
          color: color,
        );
      },
    ),
    GoRoute(
      path: '/cuestionario',
      name: 'Cuestionario',
      builder: (context, state) => const QuestionnairePage(
        auditData: {
          'auditCategories': [
            {
              'name': 'Demo',
              'auditQuestions': [
                {'id': 1, 'question': 'Demo question?'}
              ]
            }
          ]
        },
      ),
    ),
    GoRoute(
      path: '/gestionaccesos',
      name: 'Gestion de Acceso Usuario',
      builder: (context, state) => const AccessesPageUsuario(),
    ),
    GoRoute(
      path: '/accesos',
      name: 'AccessesListPage',
      builder: (context, state) => const AccessesListPage(),
    ),

    // Area and Subarea routes
    GoRoute(
        name: "AreaMenu",
        path: "/areas_menu",
        builder: (context, state) => const AreaMenu()),
    GoRoute(
        name: "AddDepartment",
        path: "/subareas",
        builder: (context, state) => const AddSubArea()),
    GoRoute(
      name: "FiveSMenu",
      path: '/fiveS/:departmentId',
      builder: (context, state) {
        final departmentId = state.pathParameters['departmentId']!;
        return FiveSMenu(departmentId: departmentId);
      },
      // Error with the parameter
      // redirect: (state) {
      //   if (state.pathParameters['departmentId'] == null) {
      //     return '/error'; // Redirige si falta el parámetro
      //   }
      //   return null;
      // }
    ),
    GoRoute(
        name: "QuestionnaireAdminMenu",
        path: '/subareas/:departmentId/5s/:fiveSId',
        builder: (context, state) {
          final departmentId = state.pathParameters['departmentId']!;
          final fiveSId = state.pathParameters['fiveSId']!;
          return QuestionnairesAdminMenu(
              departmentId: departmentId, fiveSId: fiveSId);
        }),
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
                onPrimary: _getContrastColor(themeProvider.colors.primary),
                onSecondary: _getContrastColor(themeProvider.colors.secondary)),
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
    return color.computeLuminance() > 0.4 ? Colors.black : Colors.white;
  }
}
