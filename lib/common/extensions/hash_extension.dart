import 'dart:convert';

import 'package:cats_backend/config/config.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

extension HashExtension on String {
  /// Generates a SHA-256 hash of the string.
  String get hashValue {
    final bytes = utf8.encode(this);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Encrypts the string using AES-256 encryption.
  String aes256Encrypt(String k) {
    // Generate a random IV (16 bytes for AES)
    final key = Key.fromUtf8(Config.qrCodeKey);
    final iv = IV.fromSecureRandom(16);

    // Create the encrypter
    final encrypter = Encrypter(AES(key));

    // Encrypt the string
    final encrypted = encrypter.encrypt(this, iv: iv);

    // Combine the IV and encrypted data
    // into a single string (e.g., IV:EncryptedData)
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts the string using AES-256 decryption.
  String aes256Decrypt(String key) {
    // Split the input into IV and encrypted data
    final parts = split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted data format');
    }

    // Decode the IV and encrypted data
    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);

    // Create the encrypter
    final encrypter = Encrypter(AES(Key.fromUtf8(key)));

    // Decrypt the string
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }
}
