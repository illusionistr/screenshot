import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.onDelete,
    this.onToggleLock,
  });

  final ProjectModel project;
  final VoidCallback? onDelete;
  final Function(bool)? onToggleLock;

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
                // Lock/Unlock toggle
                if (onToggleLock != null)
                  IconButton(
                    icon: Icon(
                      project.isLocked ? Icons.lock : Icons.lock_open,
                      color: project.isLocked ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () => onToggleLock?.call(!project.isLocked),
                    tooltip: project.isLocked ? 'Unlock project' : 'Lock project',
                  ),
                // Delete button
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: project.isLocked ? Colors.grey : null,
                    ),
                    onPressed: project.isLocked ? null : onDelete,
                    tooltip: project.isLocked
                        ? 'Unlock project to delete'
                        : 'Delete project',
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
                    onPressed: project.isLocked
                        ? null
                        : () {
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
                    onPressed: project.isLocked
                        ? null
                        : () {
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
              onPressed: project.isLocked
                  ? null
                  : () {
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


