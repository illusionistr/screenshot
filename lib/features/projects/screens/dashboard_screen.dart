import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to projects when we enter the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProjectProvider>().listenToProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${auth.currentUser?.email ?? ''}'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.go('/login');
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
            if (projects.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No projects yet. Create your first project!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
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
                      onDelete: () => context.read<ProjectProvider>().deleteProject(project.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


