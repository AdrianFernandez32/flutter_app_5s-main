import 'package:flutter/material.dart';

class QuestionTile extends StatelessWidget {
  final String question;
  final int questionId;
  final List<dynamic> baseItems;
  final VoidCallback? onEditQuestion;
  final VoidCallback? onDeleteQuestion;
  final VoidCallback? onAddBaseItem;
  final Function(int baseItemId, String currentItem)? onEditBaseItem;
  final Function(int baseItemId)? onDeleteBaseItem;

  const QuestionTile({
    Key? key,
    required this.question,
    required this.questionId,
    required this.baseItems,
    this.onEditQuestion,
    this.onDeleteQuestion,
    this.onAddBaseItem,
    this.onEditBaseItem,
    this.onDeleteBaseItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.primary, size: 20),
              onPressed: onEditQuestion,
              tooltip: 'Editar pregunta',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDeleteQuestion,
              tooltip: 'Eliminar pregunta',
            ),
          ],
        ),
        children: [
          // Lista de baseItems
          ...baseItems.map((item) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                ),
                title: Text(item['item'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: colorScheme.primary, size: 18),
                      onPressed: () => onEditBaseItem?.call(
                        item['id'] ?? 0,
                        item['item'] ?? '',
                      ),
                      tooltip: 'Editar respuesta',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () => onDeleteBaseItem?.call(item['id'] ?? 0),
                      tooltip: 'Eliminar respuesta',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

          // Botón para agregar nueva respuesta
          Container(
            margin: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: onAddBaseItem,
              icon: const Icon(Icons.add),
              label: const Text('Agregar respuesta'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
