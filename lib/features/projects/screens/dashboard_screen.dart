import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final projectsState = ref.watch(projectsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${currentUser?.email ?? ''}'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/projects/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Project'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: projectsState.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return Center(
                      child: Text(
                        'No projects yet. Create your first project!',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectCard(
                        project: project,
                        onDelete: () async {
                          try {
                            await ref.read(projectsNotifierProvider.notifier).deleteProject(project.id);
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting project: $error')),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const LoadingWidget(),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


