extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}

extension DateTimeX on DateTime {
  String toIsoString() => toIso8601String();
}


