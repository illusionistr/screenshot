import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/project_provider.dart';
import '../providers/upload_provider.dart';
import '../widgets/language_upload_selector.dart';
import '../widgets/screenshot_upload_section.dart';

class UploadScreenshotsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const UploadScreenshotsScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<UploadScreenshotsScreen> createState() => _UploadScreenshotsScreenState();
}

class _UploadScreenshotsScreenState extends ConsumerState<UploadScreenshotsScreen> {
  @override
  Widget build(BuildContext context) {
    final projectsStream = ref.watch(projectsStreamProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider(widget.projectId));
    final projectScreenshots = ref.watch(projectScreenshotsProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage app screens for this project'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: projectsStream.when(
        data: (projects) {
          final project = projects.where((p) => p.id == widget.projectId).firstOrNull;
          
          if (project == null) {
            return const Center(
              child: Text('Project not found'),
            );
          }

          return Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.appName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload screenshots now or skip and add them later in the editor',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    
                    // Language Selector
                    LanguageUploadSelector(
                      selectedLanguage: selectedLanguage,
                      availableLanguages: project.supportedLanguages,
                      onLanguageChanged: (languageCode) {
                        ref.read(selectedLanguageProvider(widget.projectId).notifier)
                            .setLanguage(languageCode);
                      },
                    ),
                  ],
                ),
              ),
              
              // Device Sections
              Expanded(
                child: projectScreenshots.when(
                  data: (screenshots) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(24.0),
                      itemCount: project.devices.length,
                      itemBuilder: (context, index) {
                        final device = project.devices[index];
                        final deviceScreenshots = screenshots[selectedLanguage]?[device.id] ?? [];
                        
                        return ScreenshotUploadSection(
                          projectId: widget.projectId,
                          device: device,
                          selectedLanguage: selectedLanguage,
                          screenshots: deviceScreenshots,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading screenshots: $error'),
                  ),
                ),
              ),
              
              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => context.go('/projects/${widget.projectId}/editor'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Next'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading project: $error'),
        ),
      ),
    );
  }
}