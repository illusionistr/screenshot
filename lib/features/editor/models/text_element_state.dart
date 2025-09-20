import 'text_models.dart';

class TextElementState {
  final TextFieldType? selectedType;

  const TextElementState({
    this.selectedType,
  });

  bool get hasSelection => selectedType != null;

  bool isSelected(TextFieldType type) => selectedType == type;

  TextElementState selectType(TextFieldType type) {
    return TextElementState(selectedType: type);
  }

  TextElementState clearSelection() {
    return const TextElementState();
  }

  TextElementState toggleSelection(TextFieldType type) {
    if (selectedType == type) {
      return clearSelection();
    }
    return selectType(type);
  }

  String getSelectionDisplayName() {
    return selectedType?.displayName ?? 'None';
  }

  TextElementState copyWith({
    TextFieldType? selectedType,
    bool clearSelectedType = false,
  }) {
    return TextElementState(
      selectedType: clearSelectedType ? null : (selectedType ?? this.selectedType),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextElementState && other.selectedType == selectedType;
  }

  @override
  int get hashCode => selectedType.hashCode;

  @override
  String toString() {
    return 'TextElementState(selectedType: $selectedType)';
  }
}