import 'package:flutter/material.dart';

class AreaItem extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final VoidCallback onTap;

  const AreaItem({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.surface,
                    child: logoUrl.isNotEmpty &&
                            logoUrl != "https://via.placeholder.com/150"
                        ? ClipOval(
                            child: Image.network(
                              logoUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error cargando logo: $error');
                                return Icon(
                                  Icons.business,
                                  color: colorScheme.onSurface,
                                  size: 24,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.business,
                            color: colorScheme.onSurface,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Icono de edición
                  Icon(
                    Icons.edit,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
            // Indicador circular
            Positioned(
              right: 16,
              top: 12,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
