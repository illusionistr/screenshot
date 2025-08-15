import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatefulWidget {
  final List<String> selectedLanguageCodes;
  final ValueChanged<List<String>> onSelectionChanged;
  final bool multiSelect;
  final String? title;
  final bool showRegionHeaders;
  final bool showSearch;

  const LanguageSelector({
    super.key,
    required this.selectedLanguageCodes,
    required this.onSelectionChanged,
    this.multiSelect = true,
    this.title,
    this.showRegionHeaders = true,
    this.showSearch = true,
  });

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _searchQuery = '';
  String _selectedRegion = 'All';
  List<LanguageModel> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredLanguages();
  }

  void _updateFilteredLanguages() {
    var languages = LanguageService.getAllLanguages();

    if (_selectedRegion != 'All') {
      languages = LanguageService.getLanguagesByRegion(_selectedRegion);
    }

    if (_searchQuery.isNotEmpty) {
      languages = LanguageService.searchLanguages(_searchQuery);
    }

    languages = LanguageService.sortLanguages(languages);
    
    setState(() {
      _filteredLanguages = languages;
    });
  }

  void _toggleLanguage(String languageCode) {
    final updatedSelection = List<String>.from(widget.selectedLanguageCodes);
    
    if (widget.multiSelect) {
      if (updatedSelection.contains(languageCode)) {
        updatedSelection.remove(languageCode);
      } else {
        updatedSelection.add(languageCode);
      }
    } else {
      updatedSelection.clear();
      updatedSelection.add(languageCode);
    }
    
    widget.onSelectionChanged(updatedSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        if (widget.showSearch) ...[
          TextField(
            decoration: InputDecoration(
              hintText: 'Search languages...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _updateFilteredLanguages();
            },
          ),
          const SizedBox(height: 16),
        ],
        
        if (widget.showRegionHeaders) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _RegionChip(
                  label: 'All',
                  isSelected: _selectedRegion == 'All',
                  onTap: () {
                    setState(() {
                      _selectedRegion = 'All';
                    });
                    _updateFilteredLanguages();
                  },
                ),
                const SizedBox(width: 8),
                _RegionChip(
                  label: 'Top Markets',
                  isSelected: _selectedRegion == 'Top Markets',
                  onTap: () {
                    setState(() {
                      _selectedRegion = 'Top Markets';
                      _filteredLanguages = LanguageService.getTopMarkets();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _RegionChip(
                  label: 'Americas',
                  isSelected: _selectedRegion == 'Americas',
                  onTap: () {
                    setState(() {
                      _selectedRegion = 'Americas';
                    });
                    _updateFilteredLanguages();
                  },
                ),
                const SizedBox(width: 8),
                _RegionChip(
                  label: 'Europe',
                  isSelected: _selectedRegion == 'Europe',
                  onTap: () {
                    setState(() {
                      _selectedRegion = 'Europe';
                    });
                    _updateFilteredLanguages();
                  },
                ),
                const SizedBox(width: 8),
                _RegionChip(
                  label: 'Asia',
                  isSelected: _selectedRegion == 'Asia',
                  onTap: () {
                    setState(() {
                      _selectedRegion = 'Asia';
                    });
                    _updateFilteredLanguages();
                  },
                ),
                const SizedBox(width: 8),
                _RegionChip(
                  label: 'Middle East',
                  isSelected: _selectedRegion == 'Middle East',
                  onTap: () {
                    setState(() {
                      _selectedRegion = 'Middle East';
                    });
                    _updateFilteredLanguages();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        Expanded(
          child: ListView.builder(
            itemCount: _filteredLanguages.length,
            itemBuilder: (context, index) {
              final language = _filteredLanguages[index];
              final isSelected = widget.selectedLanguageCodes.contains(language.code);
              
              return LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () => _toggleLanguage(language.code),
                multiSelect: widget.multiSelect,
              );
            },
          ),
        ),
        
        if (widget.selectedLanguageCodes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Languages (${widget.selectedLanguageCodes.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.selectedLanguageCodes.map((code) {
                    final language = LanguageService.getLanguageByCode(code);
                    if (language == null) return const SizedBox.shrink();
                    
                    return Chip(
                      label: Text(language.nativeName),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _toggleLanguage(code),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class LanguageTile extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;
  final bool multiSelect;

  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
    this.multiSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            language.code.split('-').first.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ),
      title: Text(
        LanguageService.formatLanguageDisplay(language),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w500 : null,
        ),
      ),
      subtitle: Row(
        children: [
          Text(language.code),
          if (language.isRTL) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'RTL',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: multiSelect
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
            )
          : isSelected
              ? Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                )
              : null,
    );
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w500 : null,
      ),
    );
  }
}