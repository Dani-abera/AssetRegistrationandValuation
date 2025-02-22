// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:toastification/toastification.dart';

class AssetOwnerDetailPage extends StatefulWidget {
  final String assetId;
  final String? owner;

  const AssetOwnerDetailPage({super.key, required this.assetId,this.owner});

  @override
  State<AssetOwnerDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetOwnerDetailPage> {
  String? selectedValidator;
  List<DocumentSnapshot> validators = [];
  String? assetName;
  bool validatorAssigned=false;
   bool _isValuated = false;

  void _toggleEnabled() {
    setState(()  async {
      _isValuated = !_isValuated;
      final requestdata = {
        'from': widget.owner,
        'msg': 'can you send me valuation report document of: $assetName',
        'assetName':assetName,
        'to': selectedValidator,
        'date': DateTime.now()
      };
      print(requestdata);
      try {
        await FirebaseFirestore.instance.collection('report_request').add(requestdata);
        toastification.show(
            title: Text("success"),
            type: ToastificationType.success,
            description: Text('Your report valuation request for approval to $selectedValidator is successful!'),
          );
        } catch (e) {
          toastification.show(
            title: Text("Error"),
            type: ToastificationType.error,
            description: Text('Error submitting registration: $e'),
          );
        }

      print(requestdata);
    });
  }

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
                color: Colors.black, // Background color
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
          selectedValidator = data['validator'];
          assetName = data['assetName'];
          

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
                Text('Title Deed No: ${data['titleDeedNumber'] ?? 'N/A'}'),
                Text('Asset Type: ${data['assetType'] ?? 'N/A'}'),
                Text('Asset Validator: ${data['validator'] ?? 'N/A'}'),
                Text('Validation Status: ${data['status'] ?? 'N/A'}'),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Center(child: ElevatedButton(onPressed: data['status']=='Valuated' ?_toggleEnabled:null, child: Text("Request valuation report")),)
              ],
            ),
          );
        },
      ),
    );
  }
}
