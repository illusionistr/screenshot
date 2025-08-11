import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  // Generic CRUD operations
  Future<String> createDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null) {
        await firestore.collection(collectionPath).doc(documentId).set(data);
        return documentId;
      } else {
        final doc = await firestore.collection(collectionPath).add(data);
        return doc.id;
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to create document: ${e.message}');
    }
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      final snapshot = await firestore.collection(collectionPath).doc(documentId).get();
      return snapshot.data();
    } on FirebaseException catch (e) {
      throw Exception('Failed to read document: ${e.message}');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> base)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update document: ${e.message}');
    }
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete document: ${e.message}');
    }
  }

  // File upload (for future use)
  Future<String> uploadBytes({
    required String path,
    required List<int> bytes,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      final ref = storage.ref().child(path);
      final task = await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: contentType),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }
}


