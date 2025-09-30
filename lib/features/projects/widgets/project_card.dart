import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go('/projects/${project.id}/upload');
                    },
                    icon: const Icon(Icons.cloud_upload, size: 16),
                    label: const Text('Upload'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/projects/${project.id}/editor');
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Open Editor'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                context.go('/projects/${project.id}/settings');
              },
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


