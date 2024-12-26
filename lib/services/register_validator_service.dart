import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../model/validator_model.dart';
import 'email_service.dart';

class RegisterValidatorService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  EmailSend get service => GetIt.I<EmailSend>();

  Future<String?> registerValidator(ValidatorModel validator) async {
    try {
      // Save validator data to Firestore
      await _firestore.collection('pending_validators').add(validator.toMap());

      // Optional notification
      await _firestore.collection('notifications').add({
        'message': 'New validator registration request',
        'email': validator.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> approveValidator(
      String docId, ValidatorModel validator) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: validator.email.trim(),
        password: 'Password123',
      );

      // Save approved validator to users collection
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
            validator.toMap(),
          );

      await service.sendValidatorCredentials(validator.email, 'Password123');
      await _firestore.collection('pending_validators').doc(docId).delete();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Admin Rejects Validator
  Future<void> rejectValidator(String docId) async {
    await _firestore.collection('pending_validators').doc(docId).delete();
  }
}
