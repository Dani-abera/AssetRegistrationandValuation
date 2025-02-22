import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String roomId;
  final String area;
  final String description;
  final String evaluator;
  final String status;
  final List<String> roomCurrentPhoto;

  RoomModel({
    required this.id,
    required this.roomId,
    required this.area,
    required this.description,
    required this.evaluator,
    required this.status,
    required this.roomCurrentPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId':roomId,
      'area': area,
      'description': description,
      'validator': evaluator,
      'roomCurrentPhoto':roomCurrentPhoto,
      'status': status,
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map, String documentId) {
    return RoomModel(
      id: documentId,
      roomId: map['roomId'] ?? '',
      area: map['area'] ?? '',
      description: map['description'] ?? '',
      roomCurrentPhoto: List<String>.from(map['roomCurrentPhoto'] ?? []), // ✅ Fetching list properly
      status: map['status'] ?? 'In Progress',
      evaluator: map['evaluator'] ?? 'Not Assigned',
    );
  }
}
