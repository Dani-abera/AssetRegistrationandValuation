import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'approval_page.dart';

class AdminValidatorApproval extends StatefulWidget {
  const AdminValidatorApproval({super.key});

  @override
  State<AdminValidatorApproval> createState() => _AdminValidatorApprovalState();
}

class _AdminValidatorApprovalState extends State<AdminValidatorApproval> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Validator Approvals'),
      ),
      body: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => UserDetailScreen(email: email),
          //   ),
          // );
          print('you Clicked ');
        },
        child: StreamBuilder(
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
                        onPressed: () async {
                          if (await _showConfirmationDialog(
                              context, 'approve')) {
                            _approveValidator(docId, data);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          if (await _showConfirmationDialog(
                              context, 'reject')) {
                            _rejectValidator(docId);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Show confirmation dialog before approving or rejecting
  Future<bool> _showConfirmationDialog(
      BuildContext context, String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm $action'),
            content: Text('Are you sure you want to $action this validator?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action.toUpperCase()),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Approve validator with confirmation
  Future<void> _approveValidator(
      String docId, Map<String, dynamic> data) async {
    try {
      final result = await AuthService().approveValidator(
        docId: docId,
        validatorType: data['validatorType'] ?? 'N/A',
        name: data['name'] ?? 'N/A',
        email: data['email'] ?? 'N/A',
        phoneNumber: data['phoneNumber'] ?? 'N/A',
        role: 'validator',
        cvUrl: data['cv'] ?? 'N/A',
        certificationUrl: data['certification'] ?? 'N/A',
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $result'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Validator approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Reject validator with confirmation
  Future<void> _rejectValidator(String docId) async {
    try {
      await AuthService().rejectValidator(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validator rejected'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
