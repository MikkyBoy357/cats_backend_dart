import 'dart:convert';
import 'dart:io';

import 'package:cats_backend/common/common.dart';
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
      printBlue('File Path: ${file.path}');
      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;
      firebaseOptions = FirebaseOptions.fromMap(data);
    } catch (e) {
      printRed('====> Error reading Firebase Options: $e <====');
    }

    printBlue('====> Initializing Firebase... <====');
    try {
      FirebaseDart.setup();
      app = await Firebase.initializeApp(
        options: firebaseOptions,
      );

      printMagenta('====> Firebase App initialized Successfully <====');

      storage = FirebaseStorage.instanceFor(app: app);
      printGreen(
        '==================> Connected to Firebase ✅ <==================',
      );
    } catch (e) {
      printRed('====> Error initializing Firebase: $e <====');
    }
  }
}
