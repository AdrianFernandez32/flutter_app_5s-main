import 'package:flutter/material.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_appbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/admin_navbar.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/five_s_card.dart';
import 'package:flutter_app_5s/features/user_auth/presentation/widgets/floating_plus_action_button.dart';
import 'package:go_router/go_router.dart';

class QuestionnairesAdminMenu extends StatefulWidget {
  final String departmentId;
  const QuestionnairesAdminMenu({super.key, required this.departmentId});

  @override
  State<QuestionnairesAdminMenu> createState() =>
      _QuestionnairesAdminMenuState();
}

class _QuestionnairesAdminMenuState extends State<QuestionnairesAdminMenu> {
  final List<Map<String, dynamic>> mockQuestionnaires = const [
    {
      'title': 'Cuestionario A',
      'id': '1',
    },
    {
      'title': 'Cuestionario B',
      'id': '2',
    },
    {
      'title': 'Cuestionario C',
      'id': '3',
    },
    {
      'title': 'Cuestionario D',
      'id': '4',
    },
  ];

  //TODO : use this List for the endpoint
  List<Map<String, dynamic>> questionnaires = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AdminAppBar(
        title: "Cuestionarios",
        onBackPressed: () {
          //TODO : Agregar funcionalidad
          print("Go to previous page");
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
                  ...mockQuestionnaires.map((questionnaire) => FiveSCard(
                      title: questionnaire['title'],
                      onTap: () => _handleQuestionnaireTap(
                          context, questionnaire['id'])))
                ],
              ),
            ),
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

  void _handleQuestionnaireTap(BuildContext context, String id) {
    context.pushNamed(
      'QuestionnaireAdminMenu',
      pathParameters: {'departmentId': widget.departmentId, 'fiveSId': id},
    );
  }
}
