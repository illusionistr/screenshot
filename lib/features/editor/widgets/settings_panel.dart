import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/editor_provider.dart';
import '../providers/screen_provider.dart';
import '../models/screen_settings.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final TextEditingController _annotationController = TextEditingController();
  bool _isLayoutExpanded = true;
  bool _isTextExpanded = false;
  bool _isFontExpanded = false;
  bool _isShadowExpanded = false;
  bool _isOtherExpanded = false;
  bool _isGlobalSettings = false;

  @override
  void dispose() {
    _annotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditorProvider, ScreenProvider>(
      builder: (context, editorProvider, screenProvider, child) {
        final screens = screenProvider.screens;
        final selectedIndex = editorProvider.selectedScreenIndex;
        final currentLanguage = editorProvider.currentLanguage;
        
        if (screens.isEmpty || selectedIndex >= screens.length) {
          return const Center(
            child: Text('No screen selected'),
          );
        }

        final selectedScreen = screens[selectedIndex];
        final languageName = AppConstants.supportedLanguages
            .firstWhere((lang) => lang['code'] == currentLanguage)['name'];

        // Update annotation controller when screen or language changes
        final annotation = selectedScreen.annotations[currentLanguage] ?? '';
        if (_annotationController.text != annotation) {
          _annotationController.text = annotation;
        }

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$languageName annotation for Screen #${selectedIndex + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Annotation input
                    TextField(
                      controller: _annotationController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your app description here...',
                        isDense: true,
                      ),
                      onChanged: (value) {
                        screenProvider.updateScreenAnnotation(
                          screenId: selectedScreen.id,
                          languageCode: currentLanguage,
                          annotation: value,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Global/This screen toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isGlobalSettings = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isGlobalSettings ? Colors.blue[50] : null,
                                border: Border(
                                  bottom: BorderSide(
                                    color: !_isGlobalSettings ? Colors.blue : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'This screen settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_isGlobalSettings ? Colors.blue : Colors.grey[600],
                                  fontWeight: !_isGlobalSettings ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isGlobalSettings = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _isGlobalSettings ? Colors.blue[50] : null,
                                border: Border(
                                  bottom: BorderSide(
                                    color: _isGlobalSettings ? Colors.blue : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Global settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _isGlobalSettings ? Colors.blue : Colors.grey[600],
                                  fontWeight: _isGlobalSettings ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Settings sections
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Layout section
                      _buildSettingsSection(
                        title: 'Layout',
                        isExpanded: _isLayoutExpanded,
                        onToggle: () => setState(() => _isLayoutExpanded = !_isLayoutExpanded),
                        child: _buildLayoutSettings(selectedScreen.settings),
                      ),
                      const SizedBox(height: 16),
                      
                      // Text section
                      _buildSettingsSection(
                        title: 'Text',
                        isExpanded: _isTextExpanded,
                        onToggle: () => setState(() => _isTextExpanded = !_isTextExpanded),
                        child: _buildTextSettings(selectedScreen.settings),
                      ),
                      const SizedBox(height: 16),
                      
                      // Font section
                      _buildSettingsSection(
                        title: 'Font',
                        isExpanded: _isFontExpanded,
                        onToggle: () => setState(() => _isFontExpanded = !_isFontExpanded),
                        child: _buildFontSettings(selectedScreen.settings),
                      ),
                      const SizedBox(height: 16),
                      
                      // Shadow section
                      _buildSettingsSection(
                        title: 'Shadow',
                        isExpanded: _isShadowExpanded,
                        onToggle: () => setState(() => _isShadowExpanded = !_isShadowExpanded),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            'Shadow settings coming soon...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Other options section
                      _buildSettingsSection(
                        title: 'Other options',
                        isExpanded: _isOtherExpanded,
                        onToggle: () => setState(() => _isOtherExpanded = !_isOtherExpanded),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            'Other options coming soon...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) child,
        ],
      ),
    );
  }

  Widget _buildLayoutSettings(ScreenSettings settings) {
    return Consumer2<EditorProvider, ScreenProvider>(
      builder: (context, editorProvider, screenProvider, child) {
        final selectedScreen = screenProvider.screens[editorProvider.selectedScreenIndex];
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Background type tabs
              const Text(
                'Background',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTabButton(
                    'Background Color',
                    settings.background.type == 'color',
                    () => _updateBackgroundType('color', selectedScreen),
                  ),
                  _buildTabButton(
                    'Image',
                    settings.background.type == 'image',
                    () => _updateBackgroundType('image', selectedScreen),
                  ),
                  _buildTabButton(
                    'Gradient',
                    settings.background.type == 'gradient',
                    () => _updateBackgroundType('gradient', selectedScreen),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Layout dropdown
              const Text(
                'Layout',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: settings.layout.mode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'text_above', child: Text('Text above')),
                  DropdownMenuItem(value: 'text_below', child: Text('Text below')),
                  DropdownMenuItem(value: 'text_overlay', child: Text('Text overlay')),
                ],
                onChanged: (value) => _updateLayoutMode(value!, selectedScreen),
              ),
              const SizedBox(height: 16),
              
              // Screenshot orientation
              const Text(
                'Screenshot orientation',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRadioButton(
                      'Portrait',
                      settings.layout.orientation == 'portrait',
                      () => _updateOrientation('portrait', selectedScreen),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRadioButton(
                      'Landscape',
                      settings.layout.orientation == 'landscape',
                      () => _updateOrientation('landscape', selectedScreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Frame dropdown
              const Text(
                'Frame',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: settings.layout.frameStyle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'flat_black', child: Text('Flat Mockups (Black)')),
                  DropdownMenuItem(value: 'flat_white', child: Text('Flat Mockups (White)')),
                ],
                onChanged: (value) => _updateFrameStyle(value!, selectedScreen),
              ),
              const SizedBox(height: 16),
              
              // Device margins
              const Text(
                'Device margins',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Top/Bottom'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: settings.device.margins['top']?.toString() ?? '2',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => _updateDeviceMargin('top', value, selectedScreen),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Left/Right'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: TextFormField(
                      initialValue: settings.device.margins['left']?.toString() ?? '10',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) => _updateDeviceMargin('left', value, selectedScreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Angle slider
              const Text(
                'Angle',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${settings.device.angle.toInt()}°'),
                  Expanded(
                    child: Slider(
                      value: settings.device.angle,
                      min: -45,
                      max: 45,
                      divisions: 18,
                      onChanged: (value) => _updateDeviceAngle(value, selectedScreen),
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

  Widget _buildTextSettings(ScreenSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Text settings coming soon...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildFontSettings(ScreenSettings settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Font settings coming soon...',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 16,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Update methods
  void _updateBackgroundType(String type, screenModel) {
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    final newSettings = screenModel.settings.copyWith(
      background: screenModel.settings.background.copyWith(type: type),
    );
    screenProvider.updateScreenSettings(
      screenId: screenModel.id,
      settings: newSettings,
    );
  }

  void _updateLayoutMode(String mode, screenModel) {
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    final newSettings = screenModel.settings.copyWith(
      layout: screenModel.settings.layout.copyWith(mode: mode),
    );
    screenProvider.updateScreenSettings(
      screenId: screenModel.id,
      settings: newSettings,
    );
  }

  void _updateOrientation(String orientation, screenModel) {
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    final newSettings = screenModel.settings.copyWith(
      layout: screenModel.settings.layout.copyWith(orientation: orientation),
    );
    screenProvider.updateScreenSettings(
      screenId: screenModel.id,
      settings: newSettings,
    );
  }

  void _updateFrameStyle(String frameStyle, screenModel) {
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    final newSettings = screenModel.settings.copyWith(
      layout: screenModel.settings.layout.copyWith(frameStyle: frameStyle),
    );
    screenProvider.updateScreenSettings(
      screenId: screenModel.id,
      settings: newSettings,
    );
  }

  void _updateDeviceMargin(String side, String value, screenModel) {
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    final doubleValue = double.tryParse(value) ?? 0.0;
    final margins = Map<String, double>.from(screenModel.settings.device.margins);
    
    if (side == 'top') {
      margins['top'] = doubleValue;
      margins['bottom'] = doubleValue;
    } else if (side == 'left') {
      margins['left'] = doubleValue;
      margins['right'] = doubleValue;
    }
    
    final newSettings = screenModel.settings.copyWith(
      device: screenModel.settings.device.copyWith(margins: margins),
    );
    screenProvider.updateScreenSettings(
      screenId: screenModel.id,
      settings: newSettings,
    );
  }

  void _updateDeviceAngle(double angle, screenModel) {
    final screenProvider = Provider.of<ScreenProvider>(context, listen: false);
    final newSettings = screenModel.settings.copyWith(
      device: screenModel.settings.device.copyWith(angle: angle),
    );
    screenProvider.updateScreenSettings(
      screenId: screenModel.id,
      settings: newSettings,
    );
  }
}