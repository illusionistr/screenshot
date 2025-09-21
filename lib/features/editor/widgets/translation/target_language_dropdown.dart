import 'package:flutter/material.dart';

import '../../../../core/services/translation_service.dart';

class TargetLanguageDropdown extends StatelessWidget {
  const TargetLanguageDropdown({
    super.key,
    required this.availableLanguages,
    required this.onLanguageSelected,
    required this.translatedLanguages,
  });

  final List<String> availableLanguages;
  final Function(String) onLanguageSelected;
  final Set<String> translatedLanguages;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.translate,
                  size: 16,
                  color: const Color(0xFF495057),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Target Language',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
              ],
            ),
          ),
          
          // Language list
          ...availableLanguages.map((languageCode) {
            final hasTranslation = translatedLanguages.contains(languageCode);
            final displayName = TranslationService.getLanguageDisplayName(languageCode);
            
            return InkWell(
              onTap: () => onLanguageSelected(languageCode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE1E5E9),
                      width: availableLanguages.last == languageCode ? 0 : 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Language indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: hasTranslation
                            ? const Color(0xFF28A745).withOpacity(0.1)
                            : const Color(0xFF6C757D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text(
                          languageCode.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: hasTranslation
                                ? const Color(0xFF28A745)
                                : const Color(0xFF6C757D),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Language name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF495057),
                            ),
                          ),
                          Text(
                            hasTranslation ? 'Update translation' : 'Create translation',
                            style: TextStyle(
                              fontSize: 11,
                              color: hasTranslation
                                  ? const Color(0xFF28A745)
                                  : const Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status indicator
                    if (hasTranslation)
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: const Color(0xFF28A745),
                      )
                    else
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: const Color(0xFF6C757D),
                      ),
                  ],
                ),
              ),
            );
          }),

          // Translate all option
          if (availableLanguages.length > 1)
            InkWell(
              onTap: () => onLanguageSelected('all'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Translate to All Languages',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF007BFF),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: const Color(0xFF007BFF),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}