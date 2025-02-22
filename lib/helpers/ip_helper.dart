import 'package:cats_backend/common/common.dart';
import 'package:dio/dio.dart';

Future<String?> getPublicIpAddress() async {
  final dio = Dio();

  try {
    final response = await dio.get<String?>('https://api.ipify.org');
    final ip = response.data;
    return ip;
  } catch (e) {
    printYellow('Error getting public IP address: $e');
    return null;
  }
}
