import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/editor_control_panel.dart';
import '../widgets/editor_top_bar.dart';
import '../widgets/screenshot_grid.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const EditorTopBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left control panel
          const EditorControlPanel(),

          // Main content area
          Expanded(
            child: Column(
              children: [
                // Screenshot grid
                const ScreenshotGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
