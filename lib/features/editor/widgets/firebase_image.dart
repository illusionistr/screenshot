import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Custom image widget that loads from Firebase Storage
/// Handles CORS issues with web browsers
class FirebaseImage extends StatefulWidget {
  final String storageRef;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const FirebaseImage({
    super.key,
    required this.storageRef,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<FirebaseImage> createState() => _FirebaseImageState();
}

class _FirebaseImageState extends State<FirebaseImage> {
  Uint8List? _imageData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      if (kDebugMode) {
        print('🖼️ Loading Firebase image: ${widget.storageRef}');
      }

      // Extract the storage path from the full URL
      String storagePath = widget.storageRef;
      if (storagePath.contains('firebasestorage.googleapis.com')) {
        // Parse the path from the URL
        final uri = Uri.parse(storagePath);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 4 && pathSegments[2] == 'o') {
          storagePath = Uri.decodeComponent(pathSegments[3]);
        }
      }

      if (kDebugMode) {
        print('🗂️ Parsed storage path: $storagePath');
      }

      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final data = await ref.getData();
      
      if (mounted) {
        setState(() {
          _imageData = data;
          _isLoading = false;
        });
      }

      if (kDebugMode) {
        print('✅ Firebase image loaded successfully: ${data?.length} bytes');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase image load error: $e');
      }
      
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? 
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[100],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
    }

    if (_error != null || _imageData == null) {
      return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
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
            ],
          ),
        );
    }

    return Image.memory(
      _imageData!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );
  }
}