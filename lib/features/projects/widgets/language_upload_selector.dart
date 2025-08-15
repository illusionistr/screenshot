import 'package:flutter/material.dart';

import '../../shared/data/languages_data.dart';

class LanguageUploadSelector extends StatelessWidget {
  final String selectedLanguage;
  final List<String> availableLanguages;
  final Function(String) onLanguageChanged;

  const LanguageUploadSelector({
    super.key,
    required this.selectedLanguage,
    required this.availableLanguages,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedLanguage,
      decoration: const InputDecoration(
        labelText: 'Language',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.language),
      ),
      items: availableLanguages.map((languageCode) {
        final language = LanguagesData.getLanguageByCode(languageCode);
        return DropdownMenuItem(
          value: languageCode,
          child: Row(
            children: [
              // Flag or language icon
              const Text(
                '🌐',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language?.name ?? languageCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (language?.nativeName != null && 
                        language!.nativeName != language.name) ...[
                      Text(
                        language.nativeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                languageCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onLanguageChanged(value);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a language';
        }
        return null;
      },
      isExpanded: true,
      menuMaxHeight: 300,
      dropdownColor: Theme.of(context).cardColor,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}