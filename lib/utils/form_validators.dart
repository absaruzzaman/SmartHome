/// Validation utilities for form fields
class FormValidators {
  // Email validation regex - validates standard email format
  // Supports common characters including +, -, _, and .
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates that a name field is not empty and meets minimum length
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < minLength) {
      return 'Name must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that an email field is not empty and matches proper email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates that a password field is not empty and meets minimum length
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates that a confirm password field matches the original password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
