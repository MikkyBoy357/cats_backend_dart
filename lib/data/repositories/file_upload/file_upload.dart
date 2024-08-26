import 'dart:typed_data';

import 'package:cats_backend/common/common.dart';
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

  static Future<List<UploadedFile>> getFilesFromFormData(
    FormData formData,
  ) async {
    printYellow('Files found in the form data: ${formData.files}');
    final keys = formData.files.keys.toList();
    printYellow('Keys: $keys');
    printYellow('Keys: ${formData.files['media']}');
    final files = keys.map((key) => formData.files[key]!).toList();
    return files;
  }

  static Future<List<UrlOrError>> uploadMultipleFilesAndReturnUrls({
    required List<UploadedFile> uploadedFiles,
    required String storageDir,
    double maxSizeInMB = 1,
    int maxFiles = 2,
  }) async {
    final urls = <UrlOrError>[];

    if (uploadedFiles.length > maxFiles) {
      return [
        for (var i = 0; i < maxFiles; i++)
          (url: null, error: 'Max files exceeded\nMax files: $maxFiles'),
      ];
    }

    printGreen('Uploading ${uploadedFiles.length} files...');
    for (final uploadedFile in uploadedFiles) {
      final urlOrError = await uploadFileAndReturnUrl(
        uploadedFile: uploadedFile,
        storageDir: storageDir,
        maxSizeInMB: maxSizeInMB,
      );
      urls.add(urlOrError);
    }

    return urls;
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
      printRed(
        '====> ⚠️ File ($fileSize B) exceeds max size ($maxBytes B) <====',
      );
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
      printGreen('====> Upload complete (${ref.fullPath})');
    });

    try {
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return (url: downloadUrl, error: null);
    } catch (e) {
      printRed('====> Error getting download URL: $e <====');
    }

    return (url: null, error: 'Error getting download URL');
  }
}
