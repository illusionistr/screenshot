import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../models/screen_model.dart';
import '../providers/screen_provider.dart';
import 'screenshot_uploader.dart';
import 'firebase_image.dart';

class ManageScreenshotsDialog extends StatefulWidget {
  final ScreenModel screen;
  final List<String> availableDevices;

  const ManageScreenshotsDialog({
    super.key,
    required this.screen,
    required this.availableDevices,
  });

  @override
  State<ManageScreenshotsDialog> createState() => _ManageScreenshotsDialogState();
}

class _ManageScreenshotsDialogState extends State<ManageScreenshotsDialog> {
  final GlobalKey<ScreenshotUploaderState> _uploaderKey = GlobalKey<ScreenshotUploaderState>();
  
  String? _selectedDevice;
  String? _selectedLanguage;
  bool _autoApplyToAll = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedDevice = widget.availableDevices.isNotEmpty ? widget.availableDevices.first : null;
    _selectedLanguage = 'en_US'; // Default language
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Screenshots'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Screen #${widget.screen.order + 1} Screenshots',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter controls
                  Row(
                    children: [
                      // Device filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _selectedDevice,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All devices', style: TextStyle(fontStyle: FontStyle.italic)),
                                ),
                                ...widget.availableDevices.map((device) =>
                                  DropdownMenuItem(value: device, child: Text(device)),
                                ),
                              ],
                              onChanged: (value) => setState(() => _selectedDevice = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Language filter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Language',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: _selectedLanguage,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('All languages', style: TextStyle(fontStyle: FontStyle.italic)),
                                ),
                                ...AppConstants.supportedLanguages.map((lang) =>
                                  DropdownMenuItem(
                                    value: lang['code']!,
                                    child: Text(lang['name']!),
                                  ),
                                ),
                              ],
                              onChanged: (value) => setState(() => _selectedLanguage = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Auto-apply toggle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _autoApplyToAll,
                          onChanged: (value) => setState(() => _autoApplyToAll = value ?? true),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-apply to all devices/languages',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                'When enabled, uploaded screenshots will automatically apply to all devices and languages as fallbacks',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upload Section
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey, width: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Screenshots',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          ScreenshotUploader(
                            key: _uploaderKey,
                            onFilesSelected: _handleFilesSelected,
                            allowMultiple: true,
                            showDropZone: true,
                            helpText: _getUploadHelpText(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Preview Grid Section
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Screenshots',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Expanded(
                            child: _buildScreenshotGrid(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUploadHelpText() {
    if (_selectedDevice != null && _selectedLanguage != null) {
      final deviceName = _selectedDevice!;
      final languageName = AppConstants.supportedLanguages
          .firstWhere((lang) => lang['code'] == _selectedLanguage)['name'];
      return 'Upload will apply to $deviceName ($languageName)';
    } else if (_selectedDevice != null) {
      return 'Upload will apply to ${_selectedDevice!} (all languages)';
    } else if (_selectedLanguage != null) {
      final languageName = AppConstants.supportedLanguages
          .firstWhere((lang) => lang['code'] == _selectedLanguage)['name'];
      return 'Upload will apply to all devices ($languageName)';
    } else {
      return _autoApplyToAll 
          ? 'Upload will apply to all devices and languages'
          : 'Upload will apply to specific selections';
    }
  }

  Widget _buildScreenshotGrid() {
    return Consumer<ScreenProvider>(
      builder: (context, screenProvider, child) {
        // Get the latest screen data from the provider
        final currentScreen = screenProvider.getScreenById(widget.screen.id);
        final screenshots = currentScreen?.screenshots ?? {};
        
        if (screenshots.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No screenshots uploaded yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your first screenshot to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final filteredScreenshots = _getFilteredScreenshots(screenshots);

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemCount: filteredScreenshots.length,
          itemBuilder: (context, index) {
            final entry = filteredScreenshots[index];
            return _buildScreenshotCard(entry.key, entry.value);
          },
        );
      },
    );
  }

  List<MapEntry<String, String>> _getFilteredScreenshots(Map<String, String> screenshots) {
    final screenshotEntries = screenshots.entries.toList();
    
    if (_selectedDevice == null && _selectedLanguage == null) {
      return screenshotEntries; // Show all
    }
    
    return screenshotEntries.where((entry) {
      final key = entry.key;
      
      // Check device filter
      if (_selectedDevice != null) {
        if (!key.startsWith(_selectedDevice!) && key != _selectedDevice) {
          return false;
        }
      }
      
      // Check language filter  
      if (_selectedLanguage != null) {
        if (key.contains('_')) {
          final parts = key.split('_');
          if (parts.length >= 3) {
            final langCode = '${parts[parts.length - 2]}_${parts[parts.length - 1]}';
            if (langCode != _selectedLanguage) {
              return false;
            }
          }
        } else if (_selectedLanguage != 'en_US') {
          // Default screenshots are considered en_US
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  Widget _buildScreenshotCard(String key, String url) {
    if (kDebugMode) {
      print('🖼️ Building screenshot card: $key -> $url');
    }
    
    final isDeviceSpecific = key.contains('_') && key.split('_').length >= 3;
    final deviceName = key.split('_')[0];
    final languageCode = isDeviceSpecific 
        ? key.split('_').sublist(1).join('_')
        : 'Default';
    
    String displayLabel;
    if (isDeviceSpecific) {
      final language = AppConstants.supportedLanguages
          .firstWhere((lang) => lang['code'] == languageCode, orElse: () => {'name': languageCode})['name']!;
      displayLabel = '$deviceName\n$language';
    } else {
      displayLabel = '$deviceName\nDefault';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Screenshot preview
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: FirebaseImage(
                  storageRef: url,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(height: 8),
                          Text(
                            'Loading...',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text(
                          'Failed to load',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Check console',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Label and actions
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              children: [
                Text(
                  displayLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _replaceScreenshot(key),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: const Size(0, 24),
                        ),
                        child: const Text(
                          'Replace',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _deleteScreenshot(key),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: const Size(0, 24),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleFilesSelected(List<FileUpload> files) async {
    if (files.isEmpty) return;

    setState(() => _isUploading = true);

    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);

    try {
      for (final file in files) {
        // Update progress
        _uploaderKey.currentState?.addProgressItem(file.fileName);

        try {
          await screenProvider.uploadScreenshot(
            screenId: widget.screen.id,
            device: _selectedDevice ?? widget.availableDevices.first,
            fileBytes: file.bytes,
            fileName: file.fileName,
            projectDevices: widget.availableDevices,
            mimeType: file.mimeType,
            autoApplyToAllDevices: _autoApplyToAll,
          );

          _uploaderKey.currentState?.updateProgress(
            file.fileName, 1.0, 'completed',
          );
        } catch (e) {
          _uploaderKey.currentState?.updateProgress(
            file.fileName, 0.0, 'error', error: e.toString(),
          );
        }
      }

      if (mounted) {
        showSnack(context, '${files.length} screenshot(s) uploaded successfully');
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, 'Upload failed: $e', isError: true);
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _replaceScreenshot(String key) {
    // Set filters to match the screenshot being replaced
    final parts = key.split('_');
    setState(() {
      _selectedDevice = parts[0];
      if (parts.length >= 3) {
        _selectedLanguage = parts.sublist(1).join('_');
      } else {
        _selectedLanguage = 'en_US'; // Default
      }
      _autoApplyToAll = false; // Replace specific version
    });

    showSnack(context, 'Upload a new file to replace this screenshot');
  }

  void _deleteScreenshot(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Screenshot'),
        content: const Text('Are you sure you want to delete this screenshot? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDeleteScreenshot(key);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteScreenshot(String key) async {
    // This would require extending the ScreenshotManager to support deletion
    // For now, show a message about the functionality
    showSnack(context, 'Delete functionality will be implemented in the next phase');
  }
}