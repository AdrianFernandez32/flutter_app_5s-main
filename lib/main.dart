import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/acceso_admin.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/admin_pages/add_subareas.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/admin_pages/admin_dashboard.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/admin_pages/areas_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/admin_pages/five_s_menu.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/admin_pages/questions_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/areas_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/audit_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/audits_page.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/create_organization_page.dart';
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
import 'package:flutter_app_5s/features/user_auth/presentation/pages/organizations_list_page.dart';
import 'package:flutter_app_5s/utils/global_states/admin_id_provider.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/pages/s_selection_page.dart';

void main() async {
  // await Supabase.initialize(
  //   url: 'https://rzbqldwiqhcxgjoufrzs.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6YnFsZHdpcWhjeGdqb3VmcnpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTAzNzI1NDIsImV4cCI6MjAyNTk0ODU0Mn0.2vSOwP4wBIv5lwztvsCkr97iyjw9dS0l-BCH0ndbyGI',
  // );
  //  Change Notifier Provider for the theme changes
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdminIdProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      path: '/admin_dashboard',
      name: 'AdminDashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/inicio_admin',
      name: 'InicioAdmin',
      builder: (context, state) => const InicioAdminPage(),
    ),
    GoRoute(
      path: '/android/com.example.flutterapp5s/callback',
      name: 'Auth0Callback',
      builder: (context, state) => const AdminAccessPage(),
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
          historicAudits: const [],
          selectedAudit: null,
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
        final subareaId = int.parse(state.pathParameters['subareaId']!);
        final subareaName = state.pathParameters['subareaName']!;
        final color = state.extra as Color? ?? Colors.black;
        return AuditsPage(
          subareaId: subareaId,
          subareaName: subareaName,
          color: color,
        );
      },
    ),
    GoRoute(
      path: '/SSelection',
      name: 'SSelection',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SSelectionPage(
          auditData: extra['auditData'],
          subareaId: extra['subareaId'],
          subareaName: extra['subareaName'],
        );
      },
    ),
    GoRoute(
      path: '/cuestionario',
      name: 'Cuestionario',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Faltan datos para el cuestionario.')),
          );
        }
        return QuestionnairePage(
          auditData: data['auditData'] as Map<String, dynamic>,
          selectedS: data['selectedS'] as String,
          subareaId: data['subareaId'] as int,
          subareaName: data['subareaName'] as String,
        );
      },
    ),
    GoRoute(
      path: '/gestionaccesos/:userId',
      name: 'Gestion de Acceso Usuario',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return AccessesPageUsuario(userId: userId);
      },
    ),
    GoRoute(
      path: '/accesos',
      name: 'AccessesListPage',
      builder: (context, state) => const AccessesListPage(),
    ),
    GoRoute(
      path: '/organizations',
      name: 'OrganizationsListPage',
      builder: (context, state) => const OrganizationsListPage(),
    ),
    // Area and Subarea routes
    GoRoute(
      name: "AreaMenu",
      path: "/areas_menu",
      builder: (context, state) => const AreaMenu(),
    ),
    GoRoute(
      name: "AddSubArea",
      path: "/subareas",
      builder: (context, state) => const AddSubArea(),
    ),
    GoRoute(
      name: "FiveSMenu",
      path: '/fiveS',
      builder: (context, state) {
        final idProvider = Provider.of<AdminIdProvider>(context, listen: false);
        final subareaId = idProvider.subareaId;
        final subareaName = state.extra as String? ?? 'Subárea';

        if (subareaId == null) {
          return const Center(child: Text('No se ha seleccionado una subárea'));
        }

        return FiveSMenu(
          subareaId: subareaId,
          subareaName: subareaName,
        );
      },
    ),
    GoRoute(
      name: "QuestionsPage",
      path: '/questions',
      builder: (context, state) => AdminQuestionsPage(),
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
