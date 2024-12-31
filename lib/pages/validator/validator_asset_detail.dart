import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:land_house_verify/pages/validator/valuation_Input_page.dart';
import 'package:photo_view/photo_view.dart';

class AssetValuatorDetailPage extends StatefulWidget {
  final String assetId;

  const AssetValuatorDetailPage({super.key, required this.assetId});

  @override
  State<AssetValuatorDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetValuatorDetailPage> {
  String? valuationStatus;
  List<DocumentSnapshot> validators = [];
  String? validatorName;

  static const String STATUS_NOT_VALUATED = 'Not valuated';
  static const String STATUS_IN_PROGRESS = 'In progress';
  static const String STATUS_VALUATED = 'Valuated';

  @override
  void initState() {
    super.initState();
    _fetchValidators();
    _initializeStatus();
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

  Future<void> _initializeStatus() async {
    final doc = await FirebaseFirestore.instance
        .collection('assets')
        .doc(widget.assetId)
        .get();

    if (mounted) {
      final status = doc.data()?['status']?.toString();
      debugPrint('Fetched status from Firestore: $status');
      setState(() {
        valuationStatus = status == 'In progress'
            ? STATUS_IN_PROGRESS
            : status == 'Valuated'
                ? STATUS_VALUATED
                : STATUS_NOT_VALUATED;
      });
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered,
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
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

  Widget _styledText(String label, String value) {
    return Text(
      '$label: ${value.isNotEmpty ? value : 'N/A'}',
      style: const TextStyle(fontSize: 16),
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
                const Divider(),
                _styledText('Asset ID', widget.assetId),
                _styledText('Ownership', data['ownership'] ?? ''),
                _styledText('Area', '${data['area'] ?? ''} m²'),
                _styledText('Location', data['location'] ?? ''),
                _styledText('Title Deed No', data['titleDeedNumber'] ?? ''),
                _styledText('Asset Type', data['assetType'] ?? ''),
                _styledText('Asset Valuator', data['validator'] ?? ''),
                Row(
                  children: [
                    const Text("Valuation Status:"),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButtonFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                          ),
                          value: valuationStatus ?? STATUS_NOT_VALUATED,
                          items: [
                            STATUS_NOT_VALUATED,
                            STATUS_IN_PROGRESS,
                            STATUS_VALUATED
                          ].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              valuationStatus = value as String;
                              FirebaseFirestore.instance
                                  .collection('assets')
                                  .doc(widget.assetId)
                                  .update({'status': value});
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                _styledText('Description', data['description'] ?? ''),
                const SizedBox(height: 20),
                Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [Colors.lightGreen, Colors.greenAccent],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ValidationInputScreen(
                            assetId: widget.assetId,
                            assetInfo: data,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text(
                      "Valuate this Asset",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
