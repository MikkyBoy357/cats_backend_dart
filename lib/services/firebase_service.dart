import 'dart:convert';
import 'dart:io';

import 'package:cats_backend/config/config.dart';
import 'package:firebase_dart/firebase_dart.dart';

late FirebaseApp app;
late FirebaseStorage storage;

late FirebaseOptions firebaseOptions;

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      // read firebase_options file as Map
      final file = File(Config.firebaseOptionsDir);
      print('File Path: ${file.path}');
      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;
      firebaseOptions = FirebaseOptions.fromMap(data);
    } catch (e) {
      print('====> Error reading Firebase Options: $e <====');
    }

    print('====> Initializing Firebase... <====');
    try {
      FirebaseDart.setup();
      app = await Firebase.initializeApp(
        options: firebaseOptions,
      );

      print('====> Firebase App initialized Successfully <====');

      storage = FirebaseStorage.instanceFor(app: app);
      print('==================> Connected to Firebase ✅ <==================');
    } catch (e) {
      print('====> Error initializing Firebase: $e <====');
    }
  }
}
