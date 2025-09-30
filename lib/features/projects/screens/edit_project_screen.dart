import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../features/shared/widgets/language_selector.dart';
import '../../../features/shared/widgets/responsive_layout.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';
import '../widgets/device_selector.dart';
import '../widgets/platform_selector.dart';
import '../widgets/project_edit_warning_dialog.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final String projectId;

  const EditProjectScreen({super.key, required this.projectId});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appNameCtrl;
  late List<String> _platforms;
  late List<String> _deviceIds;
  late List<String> _supportedLanguages;

  ProjectModel? _project;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _appNameCtrl = TextEditingController();
    _platforms = [];
    _deviceIds = [];
    _supportedLanguages = [];
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    super.dispose();
  }

  void _loadProject(ProjectModel project) {
    if (_project == null) {
      // Only initialize once
      setState(() {
        _project = project;
        _appNameCtrl.text = project.appName;
        _platforms = List.from(project.platforms);
        _deviceIds = List.from(project.deviceIds);
        _supportedLanguages = List.from(project.supportedLanguages);
        _isLoading = false;
      });
    }
  }

  Future<bool> _confirmDeviceRemoval(String deviceId) async {
    final screenshotCount = _project!.getImpactOfRemovingDevice(deviceId);
    final breakdown = _project!.getScreenshotBreakdownForDevice(deviceId);

    if (screenshotCount == 0) {
      return true; // No impact, allow removal without warning
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProjectEditWarningDialog(
        type: 'device',
        itemId: deviceId,
        screenshotCount: screenshotCount,
        breakdown: breakdown,
      ),
    );

    return result ?? false;
  }

  Future<bool> _confirmLanguageRemoval(String languageCode) async {
    final screenshotCount = _project!.getImpactOfRemovingLanguage(languageCode);
    final textElementCount = _project!.getTextElementsCountForLanguage(languageCode);
    final breakdown = _project!.getScreenshotBreakdownForLanguage(languageCode);

    if (screenshotCount == 0 && textElementCount == 0) {
      return true; // No impact, allow removal without warning
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ProjectEditWarningDialog(
        type: 'language',
        itemId: languageCode,
        screenshotCount: screenshotCount,
        textElementCount: textElementCount,
        breakdown: breakdown,
      ),
    );

    return result ?? false;
  }

  Future<void> _handleDeviceChange(List<String> newDeviceIds) async {
    // Check if any devices are being removed
    final removedDevices = _deviceIds.where((id) => !newDeviceIds.contains(id)).toList();

    for (final deviceId in removedDevices) {
      final confirmed = await _confirmDeviceRemoval(deviceId);
      if (!confirmed) {
        // User cancelled, don't update the device list
        return;
      }
    }

    setState(() {
      _deviceIds = newDeviceIds;
    });
  }

  Future<void> _handleLanguageChange(List<String> newLanguages) async {
    // Check if any languages are being removed
    final removedLanguages =
        _supportedLanguages.where((lang) => !newLanguages.contains(lang)).toList();

    for (final languageCode in removedLanguages) {
      final confirmed = await _confirmLanguageRemoval(languageCode);
      if (!confirmed) {
        // User cancelled, don't update the language list
        return;
      }
    }

    setState(() {
      _supportedLanguages = newLanguages;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one platform')),
      );
      return;
    }

    if (_deviceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one device')),
      );
      return;
    }

    if (_supportedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one language')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(projectsNotifierProvider.notifier).updateProjectSettings(
            projectId: widget.projectId,
            appName: _appNameCtrl.text.trim(),
            platforms: _platforms,
            deviceIds: _deviceIds,
            supportedLanguages: _supportedLanguages,
            currentProject: _project!,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project settings updated successfully')),
        );
        context.go('/dashboard');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating project: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return projectsAsync.when(
      data: (projects) {
        final project = projects.firstWhere(
          (p) => p.id == widget.projectId,
          orElse: () => throw Exception('Project not found'),
        );

        if (_isLoading) {
          _loadProject(project);
        }

        if (_isLoading) {
          return const Scaffold(
            body: Center(child: LoadingWidget()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Project Settings'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
          body: ResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Removing devices or languages will permanently delete associated screenshots and translations.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _appNameCtrl,
                      decoration: const InputDecoration(labelText: 'App name'),
                      validator: (v) =>
                          Validators.minLength(v, 2, fieldName: 'App name'),
                    ),
                    const SizedBox(height: 16),
                    Text('Platforms',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    PlatformSelector(
                      initialSelection: _platforms,
                      onChanged: (value) => setState(() => _platforms = value),
                    ),
                    const SizedBox(height: 16),
                    Text('Devices', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DeviceSelector(
                      selectedPlatforms: _platforms,
                      initialSelection: _deviceIds,
                      onChanged: _handleDeviceChange,
                    ),
                    const SizedBox(height: 16),
                    Text('Languages',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      height: 500,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LanguageSelector(
                        selectedLanguageCodes: _supportedLanguages,
                        onSelectionChanged: _handleLanguageChange,
                        multiSelect: true,
                        title: null,
                        showRegionHeaders: true,
                        showSearch: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Save Changes',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingWidget()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Edit Project Settings')),
        body: Center(
          child: Text('Error loading project: $error'),
        ),
      ),
    );
  }
}
