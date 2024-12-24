import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user in Firebase Authentication with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save additional user data (name, role) in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role, // Role determines if user is Admin or Validator
      });

      return null; // Success: no error message
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }

  // Validator Registration - Pending for Admin Approval
  Future<String?> registerValidator({
    required String validatorType,
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
    required String cvUrl,
    required String certificationUrl,
  }) async {
    try {
      // Save validator data in 'pending_validators' for admin approval
      await _firestore.collection('pending_validators').add({
        'validatorType': validatorType,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'cv': cvUrl,
        'role': 'validator',
        'certification': certificationUrl,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      // Notify admin (optional - can add notification logic)
      await _firestore.collection('notifications').add({
        'message': 'New validator registration request',
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Helper method to send email
  Future<void> _sendValidatorCredentials(String email, String password) async {
    //  email credentials
    String username = 'daniabera74@gmail.com';
    String password = 'ybot wtyf yhmp wnxr'; //  app-specific password for Gmail

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'LandHouseVerify')
      ..recipients.add(email)
      ..subject = 'Your Validator Account Credentials'
      ..text = '''
        Welcome as an approved validator!
        
        Here are your login credentials:
        Email: $email
        Password: $password
        
        Please change your password after your first login.
        
        Best regards,
        Your App Team
      ''';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  // Admin Approves Validator
  Future<String?> approveValidator({
    required String docId,
    required String validatorType,
    required String name,
    required String email,
    required String phoneNumber,
    required String role,
    required String cvUrl,
    required String certificationUrl,
  }) async {
    try {
      // Create User in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: 'defaultPassword123', // Generate or assign temporary password
      );
      // Save additional user data (name, role) in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role, // Role determines if user is Admin or User
      });

      // Save Approved Validator to Firestore (Based on Type)
      final userId = userCredential.user!.uid;
      if (validatorType == 'Individual') {
        await _firestore.collection('Individual').doc(userId).set({
          'validatorType': validatorType,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': role,
          'cv': cvUrl,
          'certification': certificationUrl,
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('Organization').doc(userId).set({
          'validatorType': validatorType,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': role,
          'cv': cvUrl,
          'certification': certificationUrl,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // Send email with login credentials
      await _sendValidatorCredentials(email, 'defaultPassword123');
      // Remove from pending list after approval
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

  // Function to handle user login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Fetch the user's role from Firestore to determine access level
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return userDoc['role']; // Return the user's role (Admin/Validator)
    } catch (e) {
      return e.toString(); // Error: return the exception message
    }
  }

  // for user log out
  signOut() async {
    _auth.signOut();
  }
}
