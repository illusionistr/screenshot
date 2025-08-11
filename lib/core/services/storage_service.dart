import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadBytes({
    required String path,
    required Uint8List data,
    String contentType = 'application/octet-stream',
  }) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putData(
      data,
      SettableMetadata(contentType: contentType),
    );
    return task.ref.getDownloadURL();
  }
}


