import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetToImageConverter {
  WidgetToImageConverter._();

  /// Convert a Flutter widget to a high-resolution PNG image
  static Future<Uint8List> convertWidgetToImage({
    required Widget widget,
    required Size targetSize,
    double pixelRatio = 1.0,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    // Create a RepaintBoundary to capture the widget
    final repaintBoundary = RepaintBoundary(
      child: MediaQuery(
        data: MediaQueryData(
          size: targetSize,
          devicePixelRatio: pixelRatio,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox(
              width: targetSize.width,
              height: targetSize.height,
              child: widget,
            ),
          ),
        ),
      ),
    );

    // Create a RenderView to render the widget
    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: RenderConstrainedBox(
          additionalConstraints: BoxConstraints(
            minWidth: targetSize.width,
            maxWidth: targetSize.width,
            minHeight: targetSize.height,
            maxHeight: targetSize.height,
          ),
          child: RenderRepaintBoundary(),
        ),
      ),
      configuration: ViewConfiguration(
        devicePixelRatio: pixelRatio,
      ),
    );

    // Build the element tree
    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    
    final element = repaintBoundary.createElement();
    buildOwner.lockState(() {
      element.mount(null, null);
    });

    // Force a frame to ensure everything is laid out
    buildOwner.buildScope(element);
    buildOwner.finalizeTree();
    
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    // Get the RepaintBoundary from the element tree
    RepaintBoundary? repaintBoundaryWidget;
    element.visitChildren((element) {
      if (element.widget is RepaintBoundary) {
        repaintBoundaryWidget = element.widget as RepaintBoundary;
      }
    });

    if (repaintBoundaryWidget == null) {
      throw Exception('Could not find RepaintBoundary in widget tree');
    }

    // Find the RenderRepaintBoundary
    RenderRepaintBoundary? renderRepaintBoundary;
    element.visitChildElements((element) {
      element.visitChildElements((element) {
        if (element.renderObject is RenderRepaintBoundary) {
          renderRepaintBoundary = element.renderObject as RenderRepaintBoundary;
        }
      });
    });

    if (renderRepaintBoundary == null) {
      throw Exception('Could not find RenderRepaintBoundary');
    }

    // Capture the image
    final image = await renderRepaintBoundary!.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: format);
    
    // Clean up
    element.unmount();
    image.dispose();
    
    return byteData!.buffer.asUint8List();
  }

  /// Simpler approach using a global overlay to render the widget
  static Future<Uint8List> convertWidgetToImageSimple({
    required Widget widget,
    required Size targetSize,
    double pixelRatio = 3.0, // High DPI for export quality
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    final completer = Completer<Uint8List>();
    
    // Create a temporary overlay entry to render the widget off-screen
    OverlayEntry? overlayEntry;
    
    final repaintBoundary = RepaintBoundary(
      key: GlobalKey(),
      child: Container(
        width: targetSize.width,
        height: targetSize.height,
        child: MediaQuery(
          data: MediaQueryData(
            size: targetSize,
            devicePixelRatio: pixelRatio,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: widget,
          ),
        ),
      ),
    );

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -targetSize.width * 2, // Position off-screen
        top: -targetSize.height * 2,
        child: repaintBoundary,
      ),
    );

    // We'll need access to an overlay - this approach requires a BuildContext
    // For now, let's return to the direct Canvas approach but use the widget system
    
    throw UnimplementedError('This approach requires BuildContext - use convertWidgetToCanvas instead');
  }

  /// Convert widget to Canvas drawing commands for direct export
  static Future<void> renderWidgetToCanvas({
    required Widget widget,
    required Canvas canvas,
    required Size targetSize,
    double pixelRatio = 1.0,
  }) async {
    // This is a simplified approach that converts common widgets to Canvas operations
    // For complex widgets, we'd need a full widget-to-canvas converter
    
    if (widget is Container) {
      await _renderContainerToCanvas(widget, canvas, targetSize);
    } else if (widget is Stack) {
      await _renderStackToCanvas(widget, canvas, targetSize);
    } else if (widget is Column) {
      await _renderColumnToCanvas(widget, canvas, targetSize);
    }
    // Add more widget types as needed
  }

  static Future<void> _renderContainerToCanvas(Container container, Canvas canvas, Size size) async {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    if (container.decoration != null && container.decoration is BoxDecoration) {
      final decoration = container.decoration as BoxDecoration;
      
      final paint = Paint();
      
      if (decoration.color != null) {
        paint.color = decoration.color!;
        canvas.drawRect(rect, paint);
      }
      
      if (decoration.border != null) {
        final borderPaint = Paint()
          ..color = decoration.border!.top.color
          ..strokeWidth = decoration.border!.top.width
          ..style = PaintingStyle.stroke;
        
        if (decoration.borderRadius != null) {
          final borderRadius = decoration.borderRadius as BorderRadius;
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, borderRadius.topLeft), 
            borderPaint
          );
        } else {
          canvas.drawRect(rect, borderPaint);
        }
      }
    }
  }

  static Future<void> _renderStackToCanvas(Stack stack, Canvas canvas, Size size) async {
    // Render children in order
    for (final child in stack.children) {
      await renderWidgetToCanvas(
        widget: child,
        canvas: canvas,
        targetSize: size,
      );
    }
  }

  static Future<void> _renderColumnToCanvas(Column column, Canvas canvas, Size size) async {
    // This would need layout calculations
    // For now, just render children
    for (final child in column.children) {
      await renderWidgetToCanvas(
        widget: child,
        canvas: canvas,
        targetSize: size,
      );
    }
  }
}