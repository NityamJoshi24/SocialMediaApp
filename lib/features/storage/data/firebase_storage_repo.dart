import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media_app/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileByte(fileBytes, fileName, "profile_images");
  }

  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "post_images");
  }

  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileByte(fileBytes, fileName, "post_images");
  }

  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      final file = File(path);

      final storageRef = storage.ref().child('$folder/$fileName');

      final uploadTask = await storageRef.putFile(file);

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> _uploadFileByte(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      final storageRef = storage.ref().child('$folder/$fileName');

      final uploadTask = await storageRef.putData(fileBytes);

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
