import 'package:cloud_firestore/cloud_firestore.dart';

class AssetModel {
  final String id;
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
  final DateTime createdAt;

  AssetModel({
    required this.id,
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
    required this.validator
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssetModel(
      id: documentId,
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
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
