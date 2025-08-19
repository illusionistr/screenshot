import 'package:flutter/material.dart';
import 'dynamic_screens_canvas.dart';

class DualScrollEditor extends StatefulWidget {
  const DualScrollEditor({super.key});

  @override
  State<DualScrollEditor> createState() => _DualScrollEditorState();
}

class _DualScrollEditorState extends State<DualScrollEditor> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 12,
      radius: const Radius.circular(6),
      child: RawScrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 12,
        radius: const Radius.circular(6),
        notificationPredicate: (notification) => notification.depth == 1,
        child: SingleChildScrollView(
          controller: _verticalController,
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: const DynamicScreensCanvas(),
          ),
        ),
      ),
    );
  }
}