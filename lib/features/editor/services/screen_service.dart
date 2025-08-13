import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/firebase_service.dart';
import '../models/screen_model.dart';
import '../models/screen_settings.dart';

class ScreenService {
  final FirebaseService _firebaseService;
  static const String _collectionPath = 'screens';
  final Uuid _uuid = const Uuid();

  ScreenService({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  Future<String> createScreen(ScreenModel screen) async {
    try {
      final screenData = screen.toFirestore();
      final screenId = await _firebaseService.createDocument(
        collectionPath: _collectionPath,
        data: screenData,
        documentId: screen.id.isNotEmpty ? screen.id : null,
      );
      return screenId;
    } catch (e) {
      throw Exception('Failed to create screen: $e');
    }
  }

  Future<ScreenModel> createDefaultScreen({
    required String projectId,
    required String userId,
    required int order,
  }) async {
    final now = DateTime.now();
    final screenId = _uuid.v4();

    final defaultSettings = ScreenSettings(
      background: const BackgroundSettings(
        type: 'gradient',
        gradientStart: '#FF9966',
        gradientEnd: '#FF5E62',
      ),
      layout: const LayoutSettings(
        mode: 'text_above',
        orientation: 'portrait',
        frameStyle: 'flat_black',
      ),
      text: const TextSettings(
        alignment: 'center',
        containerHeight: 15.0,
        margins: {'top': 2.0, 'bottom': 2.0, 'left': 10.0, 'right': 10.0},
        angle: 0.0,
      ),
      device: const DeviceSettings(
        margins: {'top': 2.0, 'bottom': 2.0, 'left': 10.0, 'right': 10.0},
        angle: 0.0,
      ),
      font: const FontSettings(
        family: 'Raleway',
        size: 40.0,
        weight: 'Regular',
        color: '#FFFFFF',
        lineHeight: 1.2,
      ),
    );

    final screen = ScreenModel(
      id: screenId,
      projectId: projectId,
      userId: userId,
      order: order,
      screenshots: {},
      annotations: {'en_US': 'Your app description here'},
      settings: defaultSettings,
      createdAt: now,
      updatedAt: now,
    );

    await createScreen(screen);
    return screen;
  }

  Future<void> updateScreen(String screenId, Map<String, dynamic> updates) async {
    try {
      final updateData = Map<String, dynamic>.from(updates);
      updateData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firebaseService.updateDocument(
        collectionPath: _collectionPath,
        documentId: screenId,
        data: updateData,
      );
    } catch (e) {
      throw Exception('Failed to update screen: $e');
    }
  }

  Future<void> deleteScreen(String screenId) async {
    try {
      await _firebaseService.deleteDocument(
        collectionPath: _collectionPath,
        documentId: screenId,
      );
    } catch (e) {
      throw Exception('Failed to delete screen: $e');
    }
  }

  Future<void> reorderScreens(String projectId, List<String> newOrder) async {
    try {
      final batch = _firebaseService.firestore.batch();

      for (int i = 0; i < newOrder.length; i++) {
        final screenRef = _firebaseService.firestore
            .collection(_collectionPath)
            .doc(newOrder[i]);
        batch.update(screenRef, {
          'order': i,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reorder screens: $e');
    }
  }

  Stream<List<ScreenModel>> streamProjectScreens(String projectId) {
    try {
      return _firebaseService
          .streamCollection(
            collectionPath: _collectionPath,
            queryBuilder: (query) => query
                .where('projectId', isEqualTo: projectId)
                .orderBy('order'),
          )
          .map((snapshot) => snapshot.docs
              .map((doc) => ScreenModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to stream project screens: $e');
    }
  }

  Future<ScreenModel?> getScreen(String screenId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(_collectionPath)
          .doc(screenId)
          .get();
      
      if (!doc.exists) return null;
      
      return ScreenModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get screen: $e');
    }
  }

  Future<void> updateScreenAnnotation({
    required String screenId,
    required String languageCode,
    required String annotation,
  }) async {
    try {
      await updateScreen(screenId, {
        'annotations.$languageCode': annotation,
      });
    } catch (e) {
      throw Exception('Failed to update screen annotation: $e');
    }
  }

  Future<void> updateScreenSettings({
    required String screenId,
    required ScreenSettings settings,
  }) async {
    try {
      await updateScreen(screenId, {
        'settings': settings.toMap(),
      });
    } catch (e) {
      throw Exception('Failed to update screen settings: $e');
    }
  }
}