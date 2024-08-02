import 'dart:typed_data';

import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

class FileUpload {
  static Future<UploadedFile?> getFirstFileFromFormData(
    FormData formData,
  ) async {
    // print('=== FORM FILES === ${formData.files}');

    final keys = formData.files.keys.toList();
    // print('=== KEYS === $keys');

    final firstFile = formData.files[keys.first];
    // print('=== FILE === ${await firstFile?.readAsBytes()}');

    return firstFile;
  }

  static Future<String?> uploadFileAndReturnUrl({
    required UploadedFile uploadedFile,
  }) async {
    // Upload file to cloud storage

    // Filename is the same as the original filename with
    // a timestamp to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${uploadedFile.name}_$timestamp';
    final ref = storage.ref().child('uploads/$filename');

    // Upload file
    final bytes = await uploadedFile.readAsBytes();
    final data = Uint8List.fromList(bytes);
    final uploadTask = ref.putData(data);

    // Wait for upload to complete
    // and return the download URL
    final snapshot = await uploadTask.whenComplete(() {
      print('====> Upload complete (${ref.fullPath})');
    });

    try {
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('====> Error getting download URL: $e <====');
    }

    return null;
  }
}
