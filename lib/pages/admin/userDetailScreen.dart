import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../components/show_dialog.dart';

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
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(
                          userData['name'].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1.5, height: 30),
                    _infoRow('Validator Type', userData['validatorType'],
                        Icons.badge, context),
                    _infoRow('Phone Number', userData['phoneNumber'],
                        Icons.phone, context),
                    _infoRow('Email', userData['email'], Icons.email, context),
                    _infoRow('Certification', userData['certificationPath'],
                        Icons.school, context),
                    _infoRow(
                        'CV', userData['cvPath'], Icons.description, context),
                    _infoRow('Request Date', _formatDate(userData['createdAt']),
                        Icons.date_range, context),
                    const SizedBox(height: 25),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download),
                        label: const Text('Download Files'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _infoRow(
    String title, String value, IconData icon, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$title: $value',
            style: const TextStyle(fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

String _formatDate(Timestamp? timestamp) {
  if (timestamp == null) return 'N/A';
  DateTime date = timestamp.toDate();
  return DateFormat('yyyy-MM-dd – kk:mm').format(date);
}
