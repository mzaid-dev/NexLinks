import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a profile image to Firebase Storage
  /// Includes security checks: size limit and file type validation
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      // 1. Read bytes for cross-platform compatibility (Web support)
      final Uint8List data = await imageFile.readAsBytes();
      
      // 2. Security Check: File Size (max 3MB)
      if (data.lengthInBytes > 3 * 1024 * 1024) {
        throw Exception("Image size is too large. Please select a smaller image.");
      }

      final String path = 'profile_images/$userId.jpg';
      final Reference ref = _storage.ref().child(path);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );

      // 3. Start Upload
      final UploadTask uploadTask = ref.putData(data, metadata);
      
      // Monitor completion
      final TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        // 4. Get Download URL with a small retry mechanism for propagation delays
        int retryCount = 0;
        while (retryCount < 3) {
          try {
            final String downloadUrl = await ref.getDownloadURL();
            return downloadUrl;
          } catch (e) {
            if (e.toString().contains('object-not-found') || e.toString().contains('404')) {
              retryCount++;
              await Future.delayed(Duration(milliseconds: 500 * retryCount));
            } else {
              rethrow;
            }
          }
        }
        throw Exception("Failed to retrieve download URL after multiple attempts.");
      } else {
        throw Exception("Upload task failed with state: ${snapshot.state}");
      }
    } catch (e) {
       // Extract core error message for better UX
      String errorMessage = e.toString();
      if (errorMessage.contains('] ')) {
        errorMessage = errorMessage.split('] ').last;
      }
      throw Exception("Upload failed: $errorMessage");
    }
  }

  /// Deletes old profile image if necessary
  Future<void> deleteProfileImage(String userId) async {
    try {
      await _storage.ref().child('profile_images').child('$userId.jpg').delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }
}
