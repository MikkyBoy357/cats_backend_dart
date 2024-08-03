import 'dart:typed_data';

import 'package:cats_backend/services/services.dart';
import 'package:dart_frog/dart_frog.dart';

typedef UrlOrError = ({String? url, String? error});

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

  static Future<UrlOrError> uploadFileAndReturnUrl({
    required UploadedFile uploadedFile,
    required String storageDir,
    double maxSizeInMB = 1,
  }) async {
    // Validate file size limit
    final bytes = await uploadedFile.readAsBytes();
    final data = Uint8List.fromList(bytes);

    final maxBytes = maxSizeInMB * 1024 * 1024;
    final fileSize = data.lengthInBytes;
    if (fileSize >= maxBytes) {
      print('====> ⚠️ File ($fileSize B) exceeds max size ($maxBytes B) <====');
      return (
        url: null,
        error: 'File exceeds max size\n'
            'Try uploading a smaller file\n'
            'Max size: $maxSizeInMB MB',
      );
    }

    // Filename is the same as the original filename with
    // a timestamp to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${uploadedFile.name}_$timestamp';
    final ref = storage.ref().child('$storageDir/$filename');

    // Upload file
    final uploadTask = ref.putData(data);

    // Wait for upload to complete
    // and return the download URL
    final snapshot = await uploadTask.whenComplete(() {
      print('====> Upload complete (${ref.fullPath})');
    });

    try {
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return (url: downloadUrl, error: null);
    } catch (e) {
      print('====> Error getting download URL: $e <====');
    }

    return (url: null, error: 'Error getting download URL');
  }
}
