import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';

class AdminValidatorApproval extends StatelessWidget {
  const AdminValidatorApproval({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text('Validator Approvals'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pending_validators')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          final validators = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: validators.length,
            itemBuilder: (context, index) {
              final data = validators[index].data() as Map<String, dynamic>;
              final docId = validators[index].id;

              return ListTile(
                title: Text(data['name']),
                subtitle: Text('Type: ${data['validatorType']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        _approveValidator(docId, data);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _rejectValidator(docId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _approveValidator(String docId, Map<String, dynamic> data) {
    // Call the approval method with the validator data
    AuthService().approveValidator(
      docId: docId,
      validatorType: data['validatorType'],
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      role: data['role'],
      cvUrl: data['cv'],
      certificationUrl: data['certification'],
    );
  }

  void _rejectValidator(String docId) {
    AuthService().rejectValidator(docId);
  }
}
