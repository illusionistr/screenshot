import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/editor_provider.dart';

class EditorTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const EditorTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final editorNotifier = ref.read(editorProvider.notifier);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo/Brand
          const Text(
            'LaunchMatic',
            style: TextStyle(
              color: Color(0xFF333333),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 32),

          // Test dropdown
          _DropdownButton(
            value: 'Test',
            items: const ['Test', 'Production'],
            onChanged: (value) {
              // Handle test mode change
            },
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
            items: const [
              'English (en)',
              'Spanish (es)',
              'French (fr)',
              'German (de)'
            ],
            onChanged: editorNotifier.updateSelectedLanguage,
          ),

          const SizedBox(width: 16),

          // Device selector
          _DropdownButton(
            value: editorState.selectedDevice,
            items: const ['Android Pixel 4', 'iPhone 14 Pro', 'iPad Pro'],
            onChanged: editorNotifier.updateSelectedDevice,
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

          _TopBarButton(
            text: 'Export',
            color: AppConstants.primaryColor,
            textColor: Colors.white,
            icon: Icons.download,
            onPressed: () {
              // Handle export
            },
          ),

          const SizedBox(width: 16),

          // Settings icon
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF6C757D),
            ),
            onPressed: () {
              // Handle settings
            },
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

class _DropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownButton({
    required this.value,
    required this.items,
    required this.onChanged,
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
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF495057),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
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
