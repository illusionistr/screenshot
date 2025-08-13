import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/editor_provider.dart';

class TopNavigationBar extends StatefulWidget {
  const TopNavigationBar({super.key});

  @override
  State<TopNavigationBar> createState() => _TopNavigationBarState();
}

class _TopNavigationBarState extends State<TopNavigationBar> {
  final TextEditingController _appNameController = TextEditingController();
  bool _isEditingAppName = false;

  @override
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, editorProvider, child) {
        final project = editorProvider.currentProject;
        
        if (project == null) {
          return Container(
            height: 60,
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Update controller when project changes
        if (!_isEditingAppName && _appNameController.text != project.appName) {
          _appNameController.text = project.appName;
        }

        return Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Left side
              Expanded(
                child: Row(
                  children: [
                    // App name (editable)
                    Flexible(
                      child: _isEditingAppName
                          ? TextField(
                              controller: _appNameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (value) {
                                _saveAppName(editorProvider, value);
                              },
                              onEditingComplete: () {
                                _saveAppName(editorProvider, _appNameController.text);
                              },
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditingAppName = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      project.appName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Platform icon and name
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            project.platform == 'android'
                                ? Icons.android
                                : Icons.phone_iphone,
                            size: 20,
                            color: project.platform == 'android'
                                ? Colors.green
                                : Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            project.platform == 'android' ? 'Android' : 'iOS',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Settings gear (placeholder)
                    IconButton(
                      onPressed: () {
                        // TODO: Implement settings
                      },
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
              
              // Right side
              Row(
                children: [
                  // Language dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: editorProvider.currentLanguage,
                        items: AppConstants.supportedLanguages
                            .map((lang) => DropdownMenuItem<String>(
                                  value: lang['code'],
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.language,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(lang['name']!),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? newLanguage) {
                          if (newLanguage != null) {
                            editorProvider.changeLanguage(newLanguage);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Device dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: editorProvider.selectedDevice,
                        items: editorProvider.availableDevices
                            .map((device) => DropdownMenuItem<String>(
                                  value: device,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.phone_android,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(device),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (String? newDevice) {
                          if (newDevice != null) {
                            editorProvider.changeDevice(newDevice);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Preview & Export button (placeholder)
                  ElevatedButton.icon(
                    onPressed: null, // Disabled for now
                    icon: const Icon(Icons.visibility),
                    label: const Text('Preview & Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveAppName(EditorProvider editorProvider, String newName) {
    setState(() {
      _isEditingAppName = false;
    });
    
    if (newName.trim().isNotEmpty) {
      editorProvider.updateProjectName(newName.trim());
    } else {
      // Reset to original name if empty
      _appNameController.text = editorProvider.currentProject?.appName ?? '';
    }
  }
}