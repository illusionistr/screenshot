import 'package:flutter/material.dart';

import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onDelete});

  final ProjectModel project;
  final VoidCallback? onDelete;

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
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Platforms: ${project.platforms.join(', ')}'),
            const SizedBox(height: 4),
            Text('Devices: ${project.deviceIds.length} selected'),
          ],
        ),
      ),
    );
  }
}


