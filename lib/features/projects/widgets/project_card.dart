import 'package:flutter/material.dart';

import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onDelete,
    this.onEdit,
    this.onQuickEdit,
  });

  final ProjectModel project;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit; // navigate to Editor screen
  final VoidCallback? onQuickEdit; // inline edit of project info

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.appName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (onQuickEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit project info',
                    onPressed: onQuickEdit,
                  ),
                if (onEdit != null)
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open editor'),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Platform: ${project.platform.toUpperCase()}'),
            const SizedBox(height: 4),
            Text('Devices: ${project.devices.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
