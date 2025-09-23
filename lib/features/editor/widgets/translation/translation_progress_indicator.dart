import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../projects/models/project_model.dart';
import '../../../shared/providers/translation_provider.dart';

class TranslationProgressIndicator extends ConsumerWidget {
  const TranslationProgressIndicator({
    super.key,
    required this.project,
    this.showDetails = true,
    this.compact = false,
  });

  final ProjectModel project;
  final bool showDetails;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationStateProvider(project.id));
    
    // Don't show if no active translations
    if (!translationState.hasActiveTranslations) {
      return const SizedBox.shrink();
    }

    final progress = translationState.progress;
    final progressPercentage = (progress * 100).round();
    final completedElements = translationState.completedElements;
    final totalElements = translationState.totalElements;

    if (compact) {
      return _buildCompactIndicator(progress, progressPercentage);
    }

    return _buildDetailedIndicator(
      context,
      progress,
      progressPercentage,
      completedElements,
      totalElements,
    );
  }

  Widget _buildCompactIndicator(double progress, int progressPercentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
              backgroundColor: const Color(0xFFBBDEFB),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$progressPercentage%',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedIndicator(
    BuildContext context,
    double progress,
    int progressPercentage,
    int completedElements,
    int totalElements,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
                  backgroundColor: const Color(0xFFBBDEFB),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Translating... $progressPercentage%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1976D2),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showTranslationDetails(context),
                icon: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF1976D2),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFBBDEFB),
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF1976D2)),
            minHeight: 4,
          ),
          if (showDetails) ...[
            const SizedBox(height: 8),
            Text(
              '$completedElements of $totalElements elements translated',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1976D2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTranslationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TranslationDetailsDialog(project: project),
    );
  }
}

class TranslationDetailsDialog extends ConsumerWidget {
  const TranslationDetailsDialog({
    super.key,
    required this.project,
  });

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationStateProvider(project.id));
    final elementStates = translationState.elementStates;

    final inProgressElements = elementStates.values
        .where((state) => state.status == TranslationStatus.inProgress)
        .toList();
    
    final completedElements = elementStates.values
        .where((state) => state.status == TranslationStatus.completed)
        .toList();
    
    final failedElements = elementStates.values
        .where((state) => state.status == TranslationStatus.failed)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.translate,
                    color: Color(0xFF1976D2),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Translation Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF495057),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF6C757D),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (inProgressElements.isNotEmpty) ...[
                      _buildSection(
                        'In Progress',
                        inProgressElements,
                        const Color(0xFF007BFF),
                        Icons.sync,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (completedElements.isNotEmpty) ...[
                      _buildSection(
                        'Completed',
                        completedElements,
                        const Color(0xFF28A745),
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (failedElements.isNotEmpty) ...[
                      _buildSection(
                        'Failed',
                        failedElements,
                        const Color(0xFFDC3545),
                        Icons.error,
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

  Widget _buildSection(
    String title,
    List<ElementTranslationState> elements,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$title (${elements.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...elements.map((elementState) => Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 4),
          child: Text(
            'Element ${elementState.elementId}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C757D),
            ),
          ),
        )),
      ],
    );
  }
}