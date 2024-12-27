import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../components/show_dialog.dart';
import '../../model/validator_model.dart';
import '../../services/register_validator_service.dart';

class UserDetailScreen extends StatefulWidget {
  final String email; // Email to fetch user data

  const UserDetailScreen({super.key, required this.email});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final showConfirmation = GetIt.instance<ShowConfirmationDialogClass>();
  final registerValidator = GetIt.instance<RegisterValidatorService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pending_validators')
            .where('email', isEqualTo: widget.email) // Listen for changes
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('User not found'));
          }

          final userData = users.first.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name']}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text('Validator Type: ${userData['validatorType']}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text('Phone Number : ${userData['phoneNumber']}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text('Email: ${userData['email']}'),
                const SizedBox(height: 12),
                Text('Email: ${userData['certificationPath']}'),
                const SizedBox(height: 12),
                Text('Email: ${userData['cvPath']}'),
                const SizedBox(height: 12),
                Text('Request Date: ${_formatDate(userData['createdAt'])}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return 'N/A';
  DateTime date = timestamp.toDate();
  return DateFormat('yyyy-MM-dd – kk:mm').format(date);
}
