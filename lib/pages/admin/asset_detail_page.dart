import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../components/my_button.dart';
import '../../services/asset_register_service.dart';

class AssetDetailPage extends StatefulWidget {
  final String assetId;

  const AssetDetailPage({super.key, required this.assetId});

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  String? selectedValidator;
  List<DocumentSnapshot> validators = [];

  @override
  void initState() {
    super.initState();
    _fetchValidators();
  }

  // Fetch available validators from Firestore
  Future<void> _fetchValidators() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'validator')
        .get();

    setState(() {
      validators = snapshot.docs;
    });
  }

  // Assign validator to asset
  Future<void> _assignValidator() async {
    if (selectedValidator != null) {
      await FirebaseFirestore.instance
          .collection('assets')
          .doc(widget.assetId)
          .update({
        'assignedValidator': selectedValidator,
        'validatorAssignedAt': FieldValue.serverTimestamp(),
      });
      // Save additional user data (name, role) in Firestore

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validator assigned successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a validator')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Details'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('assets')
            .doc(widget.assetId)
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Asset not found'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset Info Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Asset Name: ${data['assetName'].toUpperCase()}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Asset ID: ${data['assetId']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Ownership: ${data['ownership']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Area: ${data['area']} m²',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Location: ${data['location']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Title Deed No: ${data['titleDeedNo']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Asset Type: ${data['assetType']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(
                  thickness: 1.5,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 20),

                // Assign Validator Section
                Text(
                  'Assign Validator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5),
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Select Validator',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    value: selectedValidator,
                    items: validators.map((validator) {
                      final data = validator.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: validator.id,
                        child: Text(
                          data['name'],
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedValidator = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 25),

                MyButton(
                    text: 'Assign',
                    onTap: () {
                      _assignValidator();
                    }),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _confirmDelete(context, widget.assetId),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

void _confirmDelete(BuildContext context, String assetId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            _deleteAsset(context, assetId);
            //onDelete(); // Perform delete action
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

// Call deleteAsset from AssetRegistrationService
Future<void> _deleteAsset(BuildContext context, String assetId) async {
  final assetRegister = GetIt.instance<AssetRegisterService>();
  final result = await assetRegister.deleteAsset(assetId); // Call delete method

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asset deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete asset: $result'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
