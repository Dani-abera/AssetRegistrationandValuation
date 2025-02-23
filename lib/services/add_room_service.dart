import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/room_model.dart';

class AddRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<RoomModel?> addRoom({
    required String roomId,
    required String area,
    required String description,
    required List<String> roomCurrentPhoto,
    required String evaluator,
    required String roomEvaluationStatus,
  }) async {
    try {
      final room = RoomModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomId,
        area: area,
        description: description,
        evaluator: evaluator,
        status: roomEvaluationStatus,
        roomCurrentPhoto: roomCurrentPhoto
      );

      return room;
    } catch (e) {
      return null;
    }
  }

  // Firestore: Add Room Data Under an Asset
  Future<String?> saveRoomToAsset({required String assetId, required RoomModel room}) async {
    try {
      final assetDoc = await _firestore.collection('assets').doc(assetId).get();
      if (!assetDoc.exists) {
        return 'Asset not found';
      }

      // Fetch existing rooms
      List<dynamic> rooms = assetDoc.data()?['rooms'] ?? [];
      rooms.add(room.toMap()); // Convert to Map and Append

      // Update the Firestore document
      await _firestore.collection('assets').doc(assetId).update({'rooms': rooms});

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Fetch Rooms for an Asset
  Future<List<RoomModel>> fetchRoomsForAsset(String assetId) async {
    try {
      final assetDoc = await _firestore.collection('assets').doc(assetId).get();
      if (!assetDoc.exists) return [];

      List<dynamic> roomsData = assetDoc.data()?['rooms'] ?? [];

      return roomsData
          .map((room) => RoomModel.fromMap(room as Map<String, dynamic>, room['id'] ?? ''))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
