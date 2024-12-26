import 'package:cloud_firestore/cloud_firestore.dart';

class ValidatorModel {
  final String validatorType;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String cvUrl;
  final String certificationUrl;

  ValidatorModel({
    required this.validatorType,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.cvUrl,
    required this.certificationUrl,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'validatorType': validatorType,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'cvUrl': cvUrl,
      'certificationUrl': certificationUrl,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  // Factory to create a model from Firestore document
  factory ValidatorModel.fromMap(Map<String, dynamic> map) {
    return ValidatorModel(
      validatorType: map['validatorType'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
      cvUrl: map['cv'] ?? '',
      certificationUrl: map['certification'] ?? '',
    );
  }
}
