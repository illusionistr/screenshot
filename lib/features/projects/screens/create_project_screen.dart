import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../features/shared/widgets/responsive_layout.dart';
import '../providers/project_provider.dart';
import '../widgets/device_selector.dart';
import '../widgets/platform_selector.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameCtrl = TextEditingController();
  List<String> _platforms = [];
  Map<String, List<String>> _devices = {};

  @override
  void dispose() {
    _appNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_platforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one platform')));
      return;
    }
    await context.read<ProjectProvider>().createProject(
          appName: _appNameCtrl.text.trim(),
          platforms: _platforms,
          devices: _devices,
        );
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProjectProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: ResponsiveLayout(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _appNameCtrl,
                decoration: const InputDecoration(labelText: 'App name'),
                validator: (v) => Validators.minLength(v, 2, fieldName: 'App name'),
              ),
              const SizedBox(height: 16),
              Text('Platforms', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              PlatformSelector(
                onChanged: (value) => setState(() => _platforms = value),
              ),
              const SizedBox(height: 16),
              Text('Devices', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DeviceSelector(
                selectedPlatforms: _platforms,
                onChanged: (value) => setState(() => _devices = value),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Save project',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


