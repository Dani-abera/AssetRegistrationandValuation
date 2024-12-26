import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/register_validator_service.dart';
import '../model/validator_model.dart';

class ShowConfirmationDialogClass {
  RegisterValidatorService get service => GetIt.I<RegisterValidatorService>();

  /// Show confirmation dialog before approving or rejecting
  Future<bool> showConfirmationDialog(
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
  Future<void> approveValidator(
      BuildContext context, String docId, ValidatorModel validator) async {
    try {
      final result = await service.approveValidator(docId, validator);

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
  Future<void> rejectValidator(BuildContext context, String docId) async {
    try {
      await service.rejectValidator(docId);
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
