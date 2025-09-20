import 'package:flutter/material.dart';

import '../models/screenshot_model.dart';
import 'screenshot_thumbnail.dart';

class UploadGridView extends StatelessWidget {
  final List<ScreenshotModel> screenshots;
  final Function(ScreenshotModel)? onScreenshotTap;
  final Function(ScreenshotModel)? onScreenshotDelete;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final bool showEmptyState;
  final Widget? emptyStateWidget;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const UploadGridView({
    super.key,
    required this.screenshots,
    this.onScreenshotTap,
    this.onScreenshotDelete,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 12.0,
    this.mainAxisSpacing = 12.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.showEmptyState = true,
    this.emptyStateWidget,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (screenshots.isEmpty && showEmptyState) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: screenshots.length,
      itemBuilder: (context, index) {
        final screenshot = screenshots[index];
        return ScreenshotThumbnail(
          screenshot: screenshot,
          onTap: onScreenshotTap != null ? () => onScreenshotTap!(screenshot) : null,
          onDelete: onScreenshotDelete != null ? () => onScreenshotDelete!(screenshot) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (emptyStateWidget != null) {
      return emptyStateWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyStateTitle ?? 'No screenshots uploaded',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptyStateSubtitle ?? 'Upload screenshots to see them here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Responsive grid view that adapts to screen size
class ResponsiveUploadGridView extends StatelessWidget {
  final List<ScreenshotModel> screenshots;
  final Function(ScreenshotModel)? onScreenshotTap;
  final Function(ScreenshotModel)? onScreenshotDelete;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final bool showEmptyState;
  final Widget? emptyStateWidget;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveUploadGridView({
    super.key,
    required this.screenshots,
    this.onScreenshotTap,
    this.onScreenshotDelete,
    this.crossAxisSpacing = 12.0,
    this.mainAxisSpacing = 12.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.showEmptyState = true,
    this.emptyStateWidget,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(width);

    return UploadGridView(
      screenshots: screenshots,
      onScreenshotTap: onScreenshotTap,
      onScreenshotDelete: onScreenshotDelete,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      showEmptyState: showEmptyState,
      emptyStateWidget: emptyStateWidget,
      emptyStateTitle: emptyStateTitle,
      emptyStateSubtitle: emptyStateSubtitle,
      shrinkWrap: shrinkWrap,
      physics: physics,
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) {
      return 5; // Large screens
    } else if (width > 900) {
      return 4; // Medium screens
    } else if (width > 600) {
      return 3; // Small screens
    } else {
      return 2; // Mobile
    }
  }
}

// Grouped grid view that organizes screenshots by device and language
class GroupedUploadGridView extends StatelessWidget {
  final Map<String, Map<String, List<ScreenshotModel>>> screenshotsByLanguageAndDevice;
  final Function(ScreenshotModel)? onScreenshotTap;
  final Function(ScreenshotModel)? onScreenshotDelete;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;
  final bool showEmptyState;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const GroupedUploadGridView({
    super.key,
    required this.screenshotsByLanguageAndDevice,
    this.onScreenshotTap,
    this.onScreenshotDelete,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 12.0,
    this.mainAxisSpacing = 12.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.showEmptyState = true,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final hasScreenshots = screenshotsByLanguageAndDevice.values
        .any((deviceMap) => deviceMap.values.any((screenshots) => screenshots.isNotEmpty));

    if (!hasScreenshots && showEmptyState) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: screenshotsByLanguageAndDevice.keys.length,
      itemBuilder: (context, index) {
        final language = screenshotsByLanguageAndDevice.keys.elementAt(index);
        final deviceScreenshots = screenshotsByLanguageAndDevice[language]!;

        return _buildLanguageSection(context, language, deviceScreenshots);
      },
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    String language,
    Map<String, List<ScreenshotModel>> deviceScreenshots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            language.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),

        // Device grids
        ...deviceScreenshots.entries.map((deviceEntry) {
          final deviceId = deviceEntry.key;
          final screenshots = deviceEntry.value;

          if (screenshots.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device header
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      deviceId,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${screenshots.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Screenshots grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: screenshots.length,
                itemBuilder: (context, index) {
                  final screenshot = screenshots[index];
                  return ScreenshotThumbnail(
                    screenshot: screenshot,
                    onTap: onScreenshotTap != null ? () => onScreenshotTap!(screenshot) : null,
                    onDelete: onScreenshotDelete != null ? () => onScreenshotDelete!(screenshot) : null,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No screenshots uploaded',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload screenshots to see them organized by language and device',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}