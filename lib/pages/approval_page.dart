import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailScreen extends StatelessWidget {
  final String email; // Email to fetch user data

  const UserDetailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pending_validators')
            .where('email', isEqualTo: email) // Listen for changes
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
                Text('Name: ${userData['validatorType']}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text('Name: ${userData['phoneNumber']}',
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 12),
                Text('Email: ${userData['email']}'),
                const SizedBox(height: 12),
                Text('Age: ${userData['created_at']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
