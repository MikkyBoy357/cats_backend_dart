class Validator {
  // Validate if a string is not empty
  static void validateRequiredString(
    String value, {
    String fieldName = 'Field',
  }) {
    if (value.isEmpty) {
      throw Exception('$fieldName is required');
    }
  }

  // Validate email format
  static void validateEmail(String email) {
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      throw Exception('Please enter a valid email address');
    }
  }

  // Validate password (example: at least 8 characters, at least one number,
  // one uppercase and one lowercase letter)
  static void validatePassword(String password) {
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long');
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password)) {
      throw Exception(
          'Password must contain at least one letter and one number',);
    }
  }

// You can add more validation methods here
}
