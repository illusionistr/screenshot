class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool isRTL;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRTL,
  });

  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    bool? isRTL,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      isRTL: isRTL ?? this.isRTL,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isRTL': isRTL,
    };
  }

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      isRTL: json['isRTL'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel &&
        other.code == code &&
        other.name == name &&
        other.nativeName == nativeName &&
        other.isRTL == isRTL;
  }

  @override
  int get hashCode {
    return Object.hash(code, name, nativeName, isRTL);
  }

  @override
  String toString() {
    return 'LanguageModel(code: $code, name: $name, nativeName: $nativeName)';
  }
}