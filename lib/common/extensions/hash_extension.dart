import 'dart:convert';

import 'package:crypto/crypto.dart';

extension HashExtension on String {
  String get hashValue {
    final bytes = utf8.encode(this);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
