import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                Text(
                  'Asset Name: ${data['assetName']}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Asset ID: ${data['assetId']}'),
                Text('Ownership: ${data['ownership']}'),
                Text('Area: ${data['area']} m²'),
                Text('Location: ${data['location']}'),
                Text('Title Deed No: ${data['titleDeedNo']}'),
                Text('Asset Type: ${data['assetType']}'),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Assign Validator Section
                const Text(
                  'Assign Validator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Select Validator',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedValidator,
                  items: validators.map((validator) {
                    final data = validator.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: validator.id,
                      child: Text(data['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValidator = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _assignValidator,
                  child: const Text('Assign'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
