import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background_image_gallery.dart';
import 'background_image_upload_modal.dart';

class ImageBackgroundTab extends ConsumerWidget {
  final String? selectedImageId;
  final Function(String imageId, String imageUrl) onImageSelected;

  const ImageBackgroundTab({
    super.key,
    this.selectedImageId,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with upload button
          Row(
            children: [
              const Text(
                'Background Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showUploadModal(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Click an image to set as background. Long press to delete.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Image gallery
          Expanded(
            child: BackgroundImageGallery(
              selectedImageId: selectedImageId,
              onImageSelected: onImageSelected,
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadModal(BuildContext context) {
    BackgroundImageUploadModal.show(context);
  }
}