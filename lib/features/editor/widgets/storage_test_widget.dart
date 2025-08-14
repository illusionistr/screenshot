import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../config/dependency_injection.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/helpers.dart';
import '../services/screenshot_manager.dart';
import 'storage_debug_panel.dart';

/// Test widget for Firebase Storage functionality
/// Remove this widget in production
class StorageTestWidget extends StatefulWidget {
  const StorageTestWidget({super.key});

  @override
  State<StorageTestWidget> createState() => _StorageTestWidgetState();
}

class _StorageTestWidgetState extends State<StorageTestWidget> {
  final StorageService _storageService = serviceLocator<StorageService>();
  final ScreenshotManager _screenshotManager = serviceLocator<ScreenshotManager>();
  bool _isLoading = false;
  String _lastTestResult = '';

  Future<void> _testBasicUpload() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Testing basic upload...';
    });

    try {
      // Create a simple test image (1x1 PNG)
      final testData = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        0x00, 0x00, 0x00, 0x0D, // IHDR length
        0x49, 0x48, 0x44, 0x52, // IHDR
        0x00, 0x00, 0x00, 0x01, // width: 1
        0x00, 0x00, 0x00, 0x01, // height: 1
        0x08, 0x02, 0x00, 0x00, 0x00, // bit depth, color type, etc.
        0x90, 0x77, 0x53, 0xDE, // CRC
        0x00, 0x00, 0x00, 0x0C, // IDAT length
        0x49, 0x44, 0x41, 0x54, // IDAT
        0x08, 0x99, 0x01, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, // data
        0x02, 0x00, 0x01, // CRC
        0x00, 0x00, 0x00, 0x00, // IEND length
        0x49, 0x45, 0x4E, 0x44, // IEND
        0xAE, 0x42, 0x60, 0x82, // CRC
      ]);

      final testPath = 'test/storage-test-${DateTime.now().millisecondsSinceEpoch}.png';
      
      final url = await _storageService.uploadBytes(
        path: testPath,
        data: testData,
        contentType: 'image/png',
      );

      setState(() {
        _lastTestResult = '✅ Basic upload successful!\nURL: $url';
        _isLoading = false;
      });

      if (mounted) {
        showSnack(context, 'Basic upload test passed!');
      }
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Basic upload failed:\n$e';
        _isLoading = false;
      });

      if (mounted) {
        showSnack(context, 'Basic upload test failed: $e', isError: true);
      }
    }
  }

  Future<void> _testScreenshotUpload() async {
    setState(() {
      _isLoading = true;
      _lastTestResult = 'Testing screenshot upload with dual storage...';
    });

    try {
      // Create a slightly larger test image for screenshot test
      final testData = Uint8List.fromList(List.filled(1024, 0x00)..addAll([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
        // ... (simplified for test)
      ]));

      final result = await _screenshotManager.uploadScreenshot(
        projectId: 'test-project',
        screenId: 'test-screen',
        device: 'Test Device',
        fileBytes: testData,
        fileName: 'test-screenshot.png',
        mimeType: 'image/png',
      );

      setState(() {
        _lastTestResult = '✅ Screenshot upload successful!\n'
            'Original: ${result.originalUrl}\n'
            'Thumbnail: ${result.thumbnailUrl}\n'
            'Original size: ${result.originalSize} bytes\n'
            'Thumbnail size: ${result.thumbnailSize} bytes';
        _isLoading = false;
      });

      if (mounted) {
        showSnack(context, 'Screenshot upload test passed!');
      }
    } catch (e) {
      setState(() {
        _lastTestResult = '❌ Screenshot upload failed:\n$e';
        _isLoading = false;
      });

      if (mounted) {
        showSnack(context, 'Screenshot upload test failed: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Test'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Debug panel
            const StorageDebugPanel(),
            const SizedBox(height: 16),
            
            // Test controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Storage Tests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testBasicUpload,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: const Text('Test Basic Upload'),
                    ),
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testScreenshotUpload,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                      label: const Text('Test Screenshot Upload (Dual Storage)'),
                    ),
                    
                    if (_lastTestResult.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Last Test Result',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _lastTestResult.startsWith('✅') 
                              ? Colors.green[50] 
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _lastTestResult.startsWith('✅') 
                                ? Colors.green 
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          _lastTestResult,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _lastTestResult.startsWith('✅')
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}