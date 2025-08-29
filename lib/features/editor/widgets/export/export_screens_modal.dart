import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../projects/models/project_model.dart';
import '../../../shared/models/screenshot_model.dart';
import '../../../projects/providers/upload_provider.dart' as project_providers;
import '../../providers/editor_provider.dart';
import '../../services/batch_export_service.dart';

class ExportScreensModal extends ConsumerStatefulWidget {
  final ProjectModel project;
  const ExportScreensModal({super.key, required this.project});

  @override
  ConsumerState<ExportScreensModal> createState() => _ExportScreensModalState();
}

class _ExportScreensModalState extends ConsumerState<ExportScreensModal> {
  bool allDevices = true;
  bool allLanguages = true;
  bool structureInFolders = true;

  String? _status;
  int _completed = 0;
  int _total = 0;
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProviderFamily(widget.project));
    final screenshotsAsync = ref.watch(project_providers.projectScreenshotsProvider(widget.project.id));

    final devices = editorState.availableDevices.map((d) => d.id).toList();
    final languages = editorState.availableLanguages.isNotEmpty
        ? editorState.availableLanguages
        : ['en'];

    return AlertDialog(
      title: const Text('Export Screens'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('All devices'),
                    value: allDevices,
                    onChanged: _running ? null : (v) => setState(() => allDevices = v ?? true),
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('All languages'),
                    value: allLanguages,
                    onChanged: _running ? null : (v) => setState(() => allLanguages = v ?? true),
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Organize in folders (project/device/lang)'),
              value: structureInFolders,
              onChanged: _running ? null : (v) => setState(() => structureInFolders = v ?? true),
            ),
            const SizedBox(height: 8),
            if (_running) ...[
              LinearProgressIndicator(
                value: _total == 0 ? null : (_completed / _total).clamp(0.0, 1.0),
              ),
              const SizedBox(height: 8),
              Text(_status ?? ''),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _running ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Export'),
          onPressed: _running
              ? null
              : () async {
                  final selectedDevices = allDevices ? devices : [editorState.selectedDevice];
                  final selectedLanguages = allLanguages ? languages : [editorState.selectedLanguage];

                  final jobs = <ExportJob>[];
                  final shots = screenshotsAsync.maybeWhen(
                    data: (m) => m,
                    orElse: () => <String, Map<String, List<ScreenshotModel>>>{},
                  );

                  for (int i = 0; i < editorState.screens.length; i++) {
                    final screen = editorState.screens[i];
                    for (final deviceId in selectedDevices) {
                      for (final lang in selectedLanguages) {
                        ScreenshotModel? ss;
                        final assignedId = screen.assignedScreenshotId;
                        if (assignedId != null) {
                          final list = (shots[lang]?[deviceId]) ?? const <ScreenshotModel>[];
                          ss = list.where((s) => s.id == assignedId).firstOrNull;
                        }

                        jobs.add(ExportJob(
                          deviceId: deviceId,
                          languageCode: lang,
                          screenIndex: i,
                          isLandscape: screen.isLandscape,
                          layoutId: screen.layoutId,
                          frameVariant: editorState.selectedFrameVariant,
                          screenshot: ss,
                          background: screen.background,
                          textConfig: screen.textConfig,
                        ));
                      }
                    }
                  }

                  setState(() {
                    _running = true;
                    _total = jobs.length;
                    _completed = 0;
                  });

                  await BatchExportService.exportJobsToZip(
                    context: context,
                    project: widget.project,
                    jobs: jobs,
                    structureInFolders: structureInFolders,
                    onProgress: (c, t, label) {
                      setState(() {
                        _completed = c;
                        _total = t;
                        _status = 'Exporting ($c/$t): $label';
                      });
                    },
                  );

                  if (mounted) {
                    setState(() => _running = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Export complete'),
                    ));
                  }
                },
        ),
      ],
    );
  }
}
