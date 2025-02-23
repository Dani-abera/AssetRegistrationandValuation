import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/asset_model.dart';
import '../model/room_model.dart';

class AssetRegisterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new asset
  Future<String?> registerAsset({
    required String assetId,
    required String assetName,
    required String ownership,
    required String area,
    required String location,
    required String titleDeedNumber,
    required String assetType,
    required String description,
    required String documentFile,
    required List<String> assetThumbnails,
    required String valuator,
    required String status
  }) async {
    try {
      // 2. Create asset model
      final asset = AssetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assetId:assetId,
        assetName: assetName.toLowerCase(),
        ownership: ownership,
        area: area,
        location: location,
        titleDeedNumber: titleDeedNumber,
        assetType: assetType,
        description: description,
        documentUrl: documentFile,
        validator: valuator,
        status: status,
        assetImage: assetThumbnails,
        rooms: [],
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      await _firestore.collection('assets').add(asset.toMap());

      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
  // Add a room to an existing asset
  Future<String?> addRoomToAsset({
    required String assetId,
    required RoomModel room, // The room to be added
  }) async {
    try {
      // 1. Fetch the asset document
      final assetDoc = await _firestore.collection('assets').doc(assetId).get();

      if (assetDoc.exists) {
        // 2. Get current list of rooms
        List<dynamic> rooms = assetDoc.data()?['rooms'] ?? [];

        // 3. Add the new room to the list of rooms
        rooms.add(room.toMap()); // Convert the room to a map and add to list

        // 4. Update the asset document with the new rooms list
        await _firestore.collection('assets').doc(assetId).update({
          'rooms': rooms, // Update the rooms field
        });

        return null; // Success
      } else {
        return 'Asset not found'; // Asset doesn't exist
      }
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
  // Get all assets
  Stream<List<AssetModel>> getAssets() {
    return _firestore
        .collection('assets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssetModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single asset
  Future<AssetModel?> getAsset(String assetId) async {
    try {
      final doc = await _firestore.collection('assets').doc(assetId).get();
      if (doc.exists) {
        return AssetModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching asset: $e');
      }
      return null;
    }
  }

  // Update asset
  Future<String?> updateAsset({
    required String assetId,
    required Map<String, dynamic> updates,
    File? newDocumentFile,
  }) async {
    try {
      await _firestore.collection('assets').doc(assetId).update(updates);
      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  Stream<List<AssetModel>> getAssetsWithoutValidation() {
    return _firestore
        .collection('assets')
        .where('hasValidation', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssetModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateAssetValidationStatus(
      String assetId, bool hasValidation) async {
    await _firestore
        .collection('assets')
        .doc(assetId)
        .update({'hasValidation': hasValidation});
  }

  // Delete asset
  Future<String?> deleteAsset(String assetId) async {
    try {
      // Get asset data to delete document from storage
      // Delete from Firestore
      await _firestore.collection('assets').doc(assetId).delete();
      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
}
