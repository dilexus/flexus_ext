import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FxFirebaseUtil {
  Future<String> addImageToStorage(String path, File photo) async {
    var firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    await firebaseStorageRef.putFile(photo);
    return await firebaseStorageRef.getDownloadURL();
  }
}
