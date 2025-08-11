class Validators {
  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegExp.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? minLength(String? value, int length, {String fieldName = 'Value'}) {
    if (value == null || value.trim().length < length) {
      return '$fieldName must be at least $length characters';
    }
    return null;
  }
}


