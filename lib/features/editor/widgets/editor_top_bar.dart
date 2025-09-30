import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../projects/models/project_model.dart';
import '../../projects/providers/project_provider.dart';
import '../providers/editor_provider.dart';
// Export functionality removed - will be reimplemented
import 'export/export_screens_modal.dart';

class EditorTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const EditorTopBar({super.key, required this.project});

  final ProjectModel project;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorProv = editorByProjectIdProvider(project.id);
    final editorState = ref.watch(editorProv);
    final editorNotifier = ref.read(editorProv.notifier);
    final projectsState = ref.watch(projectsStreamProvider);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo/Brand
          const Text(
            'Screenshot Hub',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 32),

          // Project Selector
          projectsState.when(
            data: (projects) {
              // Ensure current project is in the list (in case of data sync issues)
              final availableProjects = projects.any((p) => p.id == project.id)
                  ? projects
                  : [...projects, project];

              return _DropdownButton(
                value: project.id,
                items: availableProjects.map((p) => p.id).toList(),
                onChanged: (projectId) {
                  // Only navigate if selecting a different project
                  if (projectId != project.id) {
                    context.go('/projects/$projectId/editor');
                  }
                },
                formatter: (projectId) {
                  try {
                    final selectedProject =
                        availableProjects.firstWhere((p) => p.id == projectId);
                    return selectedProject.appName;
                  } catch (e) {
                    return projectId;
                  }
                },
              );
            },
            loading: () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E5E9)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    project.appName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF495057),
                    ),
                  ),
                ],
              ),
            ),
            error: (_, __) => _DropdownButton(
              value: project.appName,
              items: [project.appName],
              onChanged: null,
            ),
          ),

          const Spacer(),

          // Auto-save indicator
          const Text(
            'Changes save automatically',
            style: TextStyle(
              color: Color(0xFF6C757D),
              fontSize: 12,
            ),
          ),

          const SizedBox(width: 24),

          // Language selector
          _DropdownButton(
            value: editorState.selectedLanguage,
            items: editorState.availableLanguages.isNotEmpty
                ? editorState.availableLanguages
                : ['en'],
            onChanged: editorNotifier.updateSelectedLanguage,
            formatter: (languageCode) => formatLanguageDisplay(languageCode),
          ),

          const SizedBox(width: 16),

          // Device selector
          _DropdownButton(
            value: editorState.selectedDevice,
            items: editorState.availableDevices.isNotEmpty
                ? editorState.availableDevices.map((d) => d.id).toList()
                : [''],
            onChanged: editorNotifier.updateSelectedDevice,
            formatter: (deviceId) =>
                formatDeviceDisplay(deviceId, editorState.availableDevices),
          ),

          const SizedBox(width: 24),

          // Action buttons
          _TopBarButton(
            text: 'Pricing',
            color: Colors.transparent,
            textColor: AppConstants.primaryColor,
            onPressed: () {
              // Handle pricing
            },
          ),

          const SizedBox(width: 12),

          // Export button
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => ExportScreensModal(project: project),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Back to Dashboard button
          OutlinedButton.icon(
            onPressed: () {
              context.go('/dashboard');
            },
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Dashboard'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C757D),
              side: const BorderSide(color: Color(0xFFE1E5E9)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE1E5E9),
        ),
      ),
    );
  }
}

String formatLanguageDisplay(String languageCode) {
  // Map language codes to display names
  const languageNames = {
    'en': 'English (en)',
    'es': 'Spanish (es)',
    'fr': 'French (fr)',
    'de': 'German (de)',
    'it': 'Italian (it)',
    'pt': 'Portuguese (pt)',
    'ru': 'Russian (ru)',
    'zh': 'Chinese (zh)',
    'ja': 'Japanese (ja)',
    'ko': 'Korean (ko)',
  };

  return languageNames[languageCode] ??
      '${languageCode.toUpperCase()} ($languageCode)';
}

String formatDeviceDisplay(String deviceId, List<dynamic> availableDevices) {
  if (deviceId.isEmpty) return 'No devices';

  try {
    final device = availableDevices.firstWhere((d) => d.id == deviceId);
    return device.name;
  } catch (e) {
    return deviceId;
  }
}

class _DropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String>? onChanged;
  final String Function(String)? formatter;

  const _DropdownButton({
    required this.value,
    required this.items,
    this.onChanged,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE1E5E9)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      formatter != null ? formatter!(item) : item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF495057),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged != null
              ? (newValue) {
                  if (newValue != null) {
                    onChanged!(newValue);
                  }
                }
              : null,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Color(0xFF6C757D),
          ),
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final VoidCallback onPressed;

  const _TopBarButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        side: color == Colors.transparent ? BorderSide(color: textColor) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
