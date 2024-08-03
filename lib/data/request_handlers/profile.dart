import 'package:cats_backend/common/common.dart';
import 'package:cats_backend/common/constants/storage_directories.dart';
import 'package:cats_backend/data/data.dart';
import 'package:cats_backend/data/repositories/file_upload/file_upload.dart';
import 'package:cats_backend/data/repositories/repositories.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class ProfileRequestHandler {
  Future<Response> handleChangeProfileAvatar({
    required User user,
    required FormData formData,
  });

  Future<Response> handleChangeProfileBio({
    required ObjectId userId,
    required String bio,
  });
}

class ProfileRequestHandlerImpl implements ProfileRequestHandler {
  final ProfileRepository _profileRepository;

  const ProfileRequestHandlerImpl({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  @override
  Future<Response> handleChangeProfileAvatar({
    required User user,
    required FormData formData,
  }) async {
    String? downloadUrl;
    String? uploadError;

    /// Check if there is image in the form data
    final files = formData.files;
    if (files.isNotEmpty) {
      final firstFile = await FileUpload.getFirstFileFromFormData(formData);

      final urlOrError = await FileUpload.uploadFileAndReturnUrl(
        uploadedFile: firstFile!,
        storageDir: StorageDirectories.avatarById(userId: user.$_id.oid),
      );

      downloadUrl = urlOrError.url;
      uploadError = urlOrError.error;

      if (uploadError != null) {
        return Response.json(
          body: {
            'message': 'Failed to upload avatar',
            'error': uploadError,
          },
          statusCode: 500,
        );
      }
    }

    // Update user avatarUrl
    final updatedUser = await _profileRepository.changeProfileAvatar(
      user: user,
      imageUrl: downloadUrl!,
    );

    return Response.json(
      body: updatedUser,
    );
  }

  @override
  Future<Response> handleChangeProfileBio({
    required ObjectId userId,
    required String bio,
  }) async {
    // TODO: implement handleChangeProfileBio
    // see handleChangeProfileAvatar for example
    throw UnimplementedError();
  }
}
