import 'dart:math';

String generateUsername(String name) {
  // Remove spaces, convert to lowercase, and take first 10 chars
  final baseName = name.replaceAll(' ', '').toLowerCase();
  final username = baseName.length > 10 ? baseName.substring(0, 10) : baseName;
  
  // Add a random suffix to make it more unique
  final randomSuffix = Random().nextInt(9999).toString().padLeft(4, '0');
  return '$username$randomSuffix';
}

// Helper function to generate a temporary password
String generateTempPassword() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
  final random = Random();
  return List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
}
String generatePasswordFromUsername(String username) {
  // Add a random number and special character to make it more secure
  final random = Random();
  final randomNum = random.nextInt(999).toString().padLeft(3, '0');
  final specialChars = ['!', '@', '#', '\$', '%', '&', '*'];
  final randomSpecial = specialChars[random.nextInt(specialChars.length)];
  
  // Create password: username + special character + random number
  return '$username$randomSpecial$randomNum';
}