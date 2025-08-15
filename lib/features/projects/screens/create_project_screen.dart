import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../features/shared/widgets/language_selector.dart';
import '../../../features/shared/widgets/responsive_layout.dart';
import '../providers/project_provider.dart';
import '../widgets/device_selector.dart';
import '../widgets/platform_selector.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameCtrl = TextEditingController();
  List<String> _platforms = [];
  List<String> _deviceIds = [];
  List<String> _supportedLanguages = ['en']; // Default to English

  @override
  void dispose() {
    _appNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one platform')));
      return;
    }

    if (_supportedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one language')));
      return;
    }

    try {
      await ref.read(projectsNotifierProvider.notifier).createProject(
            appName: _appNameCtrl.text.trim(),
            platforms: _platforms,
            deviceIds: _deviceIds,
            supportedLanguages: _supportedLanguages,
          );

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating project: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  onChanged: (value) => setState(() => _platforms = value),
                ),
                const SizedBox(height: 16),
                Text('Devices', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DeviceSelector(
                  selectedPlatforms: _platforms,
                  onChanged: (value) => setState(() => _deviceIds = value),
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
                    onSelectionChanged: (value) =>
                        setState(() => _supportedLanguages = value),
                    multiSelect: true,
                    title: null,
                    showRegionHeaders: true,
                    showSearch: true,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Save project',
                  isLoading: false,
                  onPressed: () async {
                    await _submit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
