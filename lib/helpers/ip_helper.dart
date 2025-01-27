import 'package:dio/dio.dart';

Future<String?> getPublicIpAddress() async {
  final dio = Dio();

  try {
    final response = await dio.get('https://api.ipify.org');
    final ip = response.data as String;
    return ip;
  } catch (e) {
    print('Error getting public IP address: $e');
    return null;
  }
}
