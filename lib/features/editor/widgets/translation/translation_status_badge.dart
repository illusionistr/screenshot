import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/translation_service.dart';
import '../../../projects/models/project_model.dart';
import '../../../shared/providers/translation_provider.dart';
import '../../models/text_models.dart';

enum TranslationBadgeStyle {
  compact,
  detailed,
  minimal,
}

class TranslationStatusBadge extends ConsumerWidget {
  const TranslationStatusBadge({
    super.key,
    required this.project,
    required this.element,
    this.style = TranslationBadgeStyle.compact,
    this.showProgress = true,
  });

  final ProjectModel project;
  final TextElement element;
  final TranslationBadgeStyle style;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationState = ref.watch(translationStateProvider(project.id));
    final elementState = translationState.elementStates[element.id];
    
    final targetLanguages = project.nonReferenceLanguages;
    if (targetLanguages.isEmpty) {
      return const SizedBox.shrink();
    }

    final availableTranslations = element.availableLanguages;
    final hasTranslations = availableTranslations.length > 1; // More than just reference language
    final translatedCount = availableTranslations.where((lang) => 
        lang != project.effectiveReferenceLanguage).length;
    final totalTargetCount = targetLanguages.length;
    
    // Check if currently being translated
    final isTranslating = elementState?.status == TranslationStatus.inProgress;
    
    // Check if translations are outdated (reference content changed after translation)
    final isOutdated = _hasOutdatedTranslations(element, project);

    return _buildBadge(
      context,
      translatedCount: translatedCount,
      totalCount: totalTargetCount,
      isTranslating: isTranslating,
      isOutdated: isOutdated,
      hasTranslations: hasTranslations,
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required int translatedCount,
    required int totalCount,
    required bool isTranslating,
    required bool isOutdated,
    required bool hasTranslations,
  }) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData? iconData;
    String text;

    if (isTranslating) {
      backgroundColor = const Color(0xFF007BFF).withOpacity(0.1);
      textColor = const Color(0xFF007BFF);
      borderColor = const Color(0xFF007BFF).withOpacity(0.3);
      iconData = Icons.sync;
      text = 'Translating...';
    } else if (isOutdated) {
      backgroundColor = const Color(0xFFFFC107).withOpacity(0.1);
      textColor = const Color(0xFFF57C00);
      borderColor = const Color(0xFFFFC107).withOpacity(0.3);
      iconData = Icons.warning_amber;
      text = 'Outdated';
    } else if (translatedCount == 0) {
      backgroundColor = const Color(0xFF6C757D).withOpacity(0.1);
      textColor = const Color(0xFF6C757D);
      borderColor = const Color(0xFF6C757D).withOpacity(0.3);
      iconData = Icons.translate_outlined;
      text = 'Not translated';
    } else if (translatedCount < totalCount) {
      backgroundColor = const Color(0xFFFFC107).withOpacity(0.1);
      textColor = const Color(0xFFF57C00);
      borderColor = const Color(0xFFFFC107).withOpacity(0.3);
      iconData = Icons.translate;
      text = '$translatedCount/$totalCount languages';
    } else {
      backgroundColor = const Color(0xFF28A745).withOpacity(0.1);
      textColor = const Color(0xFF28A745);
      borderColor = const Color(0xFF28A745).withOpacity(0.3);
      iconData = Icons.check_circle;
      text = 'Complete';
    }

    switch (style) {
      case TranslationBadgeStyle.minimal:
        return _buildMinimalBadge(iconData!, textColor);
      case TranslationBadgeStyle.compact:
        return _buildCompactBadge(iconData!, textColor, backgroundColor, borderColor, text);
      case TranslationBadgeStyle.detailed:
        return _buildDetailedBadge(iconData!, textColor, backgroundColor, borderColor, text, translatedCount, totalCount);
    }
  }

  Widget _buildMinimalBadge(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  Widget _buildCompactBadge(IconData icon, Color textColor, Color backgroundColor, Color borderColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBadge(IconData icon, Color textColor, Color backgroundColor, Color borderColor, String text, int translatedCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: textColor,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (totalCount > 0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: translatedCount / totalCount,
              backgroundColor: textColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
              minHeight: 2,
            ),
            const SizedBox(height: 2),
            Text(
              'Languages: $translatedCount/$totalCount',
              style: TextStyle(
                fontSize: 10,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasOutdatedTranslations(TextElement element, ProjectModel project) {
    // For now, return false - this would require timestamp tracking
    // In a full implementation, we'd track when reference content was last updated
    // and compare it to translation timestamps
    return false;
  }
}