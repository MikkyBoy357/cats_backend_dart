import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtHandler {
  JwtHandler({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  Future<User?> userFromToken(String token) async {
    try {
      final jwt = JWT.verify(token, SecretKey('secret passphrase'));
      final payload = jwt.payload as String;
      return _userRepository.getQuery(UserQuery.id, payload);
    } catch (e) {
      return null;
    }
  }
}
