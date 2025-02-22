import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:land_house_verify/model/room_model.dart';

class AssetModel {
  final String id;
  final String assetId;
  final String assetName;
  final String ownership;
  final String area;
  final String location;
  final String titleDeedNumber;
  final String assetType;
  final String description;
  final String documentUrl;
  final String validator;
  final String status;
  final List<String> assetImage;
  final List<RoomModel> rooms;
  final DateTime createdAt;


  AssetModel({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.ownership,
    required this.area,
    required this.location,
    required this.titleDeedNumber,
    required this.assetType,
    required this.description,
    required this.documentUrl,
    required this.createdAt,
    required this.assetImage,
    required this.status,
    required this.validator,
    this.rooms = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetId':assetId,
      'assetName': assetName,
      'ownership': ownership,
      'area': area,
      'location': location,
      'titleDeedNumber': titleDeedNumber,
      'assetType': assetType,
      'description': description,
      'documentUrl': documentUrl,
      'validator': validator,
      'assetImage':assetImage,
      'status': status,
      'rooms': rooms.map((room) => room.toMap()).toList(), // Convert rooms to map
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssetModel(
      id: documentId,
      assetId: map['assetName'],
      assetName: map['assetName'] ?? '',
      ownership: map['ownership'] ?? '',
      area: map['area'] ?? '',
      location: map['location'] ?? '',
      titleDeedNumber: map['titleDeedNumber'] ?? '',
      assetType: map['assetType'] ?? '',
      description: map['description'] ?? '',
      documentUrl: map['documentUrl'] ?? '',
       assetImage: ['assetImage'], 
       status: map['status'], 
       validator: map['validator'],
      rooms: (map['rooms'] as List?)
          ?.map((room) => RoomModel.fromMap(room, documentId))
          .toList() ??
          [], // Convert rooms from map to RoomModel
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
