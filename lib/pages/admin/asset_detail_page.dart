// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:land_house_verify/pages/admin/add_rooms.dart';
import 'package:photo_view/photo_view.dart';

import '../../model/room_model.dart';
import '../../services/add_room_service.dart';
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
  String? validatorName;
  bool validatorAssigned = false;
  final AddRoomService _roomService = AddRoomService();
  List<RoomModel> rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchValidators();
    _fetchRooms();
  }

  Future<void> _fetchValidators() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'validator')
          .get();

      if (!mounted) return;
      setState(() {
        validators = snapshot.docs;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching validators: $e')),
      );
    }
  }

  Future<void> _fetchValidatorName(String validatorId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(validatorId)
          .get();

      if (snapshot.exists && mounted) {
        setState(() {
          validatorName = snapshot.data()?['name'] ?? 'Unknown';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching validator name: $e')),
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
      await _fetchValidatorName(selectedValidator!);

      await FirebaseFirestore.instance
          .collection('assets')
          .doc(widget.assetId)
          .update({
        'validator': validatorName,
        'assignedValidator': selectedValidator,
        'validatorAssignedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validator assigned successfully')),
      );
      setState(() {
        validatorAssigned = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error assigning validator: $e')),
      );
    }
  }

  Future<void> _deleteAsset(BuildContext context, String assetId) async {
    final assetRegister = GetIt.instance<AssetRegisterService>();
    try {
      final result = await assetRegister.deleteAsset(assetId);
      if (result == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete asset: $e')),
      );
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
                color: Colors.black87,
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

  Widget _buildInfoCard(String title, dynamic value) {
    return SizedBox(
      height: 150, // Fixed height for the card
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize.min, // 🔥 Ensures column only takes required space
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Prevents title from taking too much space
              ),
              const SizedBox(height: 5),
              Expanded(
                // 🔥 Allows text to take remaining space without overflow
                child: Text(
                  value ?? 'N/A',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4, // Limits text lines to avoid overflow
                  softWrap: true, // Ensures text wraps properly
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchRooms() async {
    List<RoomModel> fetchedRooms =
        await _roomService.fetchRoomsForAsset(widget.assetId);
    setState(() {
      rooms = fetchedRooms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset Details')),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Asset Name: ${data['assetName'] ?? 'Unknown'}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddRoomsPage(
                                      id: data['assetId'],
                                      assetId: widget.assetId,
                                    )));
                      },
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: Image.asset(
                          "assets/images/add_rooms.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
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
                                color: Theme.of(context).colorScheme.primary),
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
                GridView.count(
                  crossAxisCount: 2, // Adjust based on screen size
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.8, // Adjust to prevent text wrapping
                  children: [
                    _buildInfoCard('Asset ID', data['assetId']),
                    _buildInfoCard('Asset Owner', data['ownership']),
                    _buildInfoCard('Area', '${data['area']} m²'),
                    _buildInfoCard('Location', data['location']),
                    _buildInfoCard('Title Deed No', data['titleDeedNumber']),
                    _buildInfoCard('Asset Type', data['assetType']),
                    _buildInfoCard('Asset Validator', data['validator']),
                    _buildInfoCard('Validation Status', data['status']),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Available Rooms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 140, // Adjust height to fit content properly
                  child: ListView.builder(
                    scrollDirection:
                        Axis.horizontal, // Enable horizontal scrolling
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return SizedBox(
                        //padding: EdgeInsets.all(16.0),
                        width: 350, // Adjust width so each card is visible
                        child: GestureDetector(
                          onTap: () {},
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                // Row layout for horizontal scroll
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  room.roomCurrentPhoto.isNotEmpty
                                      ? Image.network(
                                          room.roomCurrentPhoto.first,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported,
                                          size: 80),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Room ID: ${room.roomId}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Area: ${room.area} m²'),
                                        Text(
                                          'Status: ${room.status}',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        Text(
                                          'Description: ${room.description}',
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                validatorAssigned
                    ? Column(children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: 'Select Validator',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.5),
                            ),
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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: _assignValidator,
                              child: Center(
                                child: Text("Assign Evaluator"),
                              )),
                        )
                      ])
                    : Center(
                        child: SizedBox(
                        width: double.infinity,
                        height: 40.0,
                        child: ElevatedButton(
                          onPressed: () => setState(
                              () => validatorAssigned = !validatorAssigned),
                          child: Text(validatorAssigned
                              ? "Cancel"
                              : "Change Validator"),
                        ),
                      )),
                SizedBox(height: 10),
                Center(
                    child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete Asset'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _deleteAsset(context, widget.assetId),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
