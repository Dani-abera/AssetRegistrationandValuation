import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../components/show_dialog.dart';
import '../../model/validator_model.dart';

import '../../services/register_validator_service.dart';
import 'approval_page.dart';

class AdminValidatorApproval extends StatefulWidget {
  const AdminValidatorApproval({super.key});

  @override
  State<AdminValidatorApproval> createState() => _AdminValidatorApprovalState();
}

class _AdminValidatorApprovalState extends State<AdminValidatorApproval> {
  final showConfirmation = GetIt.instance<ShowConfirmationDialogClass>();

  final registerValidator = GetIt.instance<RegisterValidatorService>();

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserDetailScreen(
                        email: data['email'],
                      ),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          if (await showConfirmation.showConfirmationDialog(
                              context, 'approve')) {
                            final validator = ValidatorModel.fromMap(
                                data); // Convert map to model
                            showConfirmation.approveValidator(
                                context, docId, validator);
                          }
                        }),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        if (await showConfirmation.showConfirmationDialog(
                            context, 'reject')) {
                          showConfirmation.rejectValidator(context, docId);
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
    );
  }
}
