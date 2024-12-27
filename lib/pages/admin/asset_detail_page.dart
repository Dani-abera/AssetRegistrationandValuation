import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_view/photo_view.dart';

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

  Future<void> _fetchValidators() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'validator')
          .get();

      setState(() {
        validators = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching validators: $e')),
      );
    }
  }

  Future<void> _assignValidator() async {
    if (selectedValidator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a validator')),
      );
      return;
    }

    try {
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning validator: $e')),
      );
    }
  }

  Future<void> _deleteAsset(BuildContext context, String assetId) async {
    final assetRegister = GetIt.instance<AssetRegisterService>();
    try {
      final result = await assetRegister.deleteAsset(assetId);
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Close the details page
      } else {
        throw result;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete asset: $e')),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAsset(context, assetId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allows closing by tapping outside the dialog
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero, // Removes the default padding
      child: Stack(
        children: [
          // Use PhotoView to display and zoom the image
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered,
            backgroundDecoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9), // Background color
            ),
          ),
          // A close button at the top right of the image
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget buildDropdownContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      child: child,
    );
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
                  'Asset Name: ${data['assetName'] ?? 'Unknown'}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: (data['assetImage'] as List?)?.length ?? 0,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final imageUrl = data['assetImage'][index];
                      return GestureDetector(
                        onTap: () => _showImagePreview(imageUrl),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color:
                                    Theme.of(context).colorScheme.primary),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text('Asset ID: ${data['assetId'] ?? 'N/A'}'),
                Text('Ownership: ${data['ownership'] ?? 'N/A'}'),
                Text('Area: ${data['area'] ?? 'N/A'} m²'),
                Text('Location: ${data['location'] ?? 'N/A'}'),
                Text('Title Deed No: ${data['titleDeedNo'] ?? 'N/A'}'),
                Text('Asset Type: ${data['assetType'] ?? 'N/A'}'),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Assign Validator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                buildDropdownContainer(
                  DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: 'Select Validator',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    value: selectedValidator,
                    items: validators.map((validator) {
                      final data =
                          validator.data() as Map<String, dynamic>;
                      return DropdownMenuItem(
                        value: validator.id,
                        child: Text(data['name'] ?? 'Unknown'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedValidator = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Assign',
                  onTap: _assignValidator,
                ),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () =>
                        _confirmDelete(context, widget.assetId),
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
