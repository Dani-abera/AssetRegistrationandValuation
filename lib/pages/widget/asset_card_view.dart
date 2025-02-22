import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/asset-owner/owner_asset_detail.dart';
import 'package:land_house_verify/pages/validator/validator_asset_detail.dart';

class AssetsCard extends StatelessWidget {
  final String? condition;
  final String? isEqualTo;
  final String? role;
  final Widget widget;

  const AssetsCard({
    super.key,
    this.condition,
    this.isEqualTo,
    required this.widget, this.role,
  });

  @override
  Widget build(BuildContext context) {
    final String assetowner = isEqualTo!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('assets')
          .where(condition!, isEqualTo: assetowner) // Filter by the current validator's name
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading assets'));
        }
    
        final assets = snapshot.data?.docs ?? [];
    
        if (assets.isEmpty) {
          return const Center(child: Text('No assets found for you'));
    
        }
    
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
                childAspectRatio: 0.73, // Adjust the aspect ratio as needed
              ),
              itemCount: assets.length,
              itemBuilder: (context, index) {
                final data = assets[index].data() as Map<String, dynamic>;
                final docId = assets[index].id;
                final assetImage = (data['assetImage'] as List?)?.first ?? '';
                final assetName = data['assetName'] ?? 'Unknown Asset';
                final ownership = data['ownership'] ?? 'Unknown Owner';
                final validator = data['validator'] ?? 'Not Assigned';
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: assetImage.isNotEmpty
                                ? Image.network(
                                    assetImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text('Image not available'),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/image.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text('Image not available'),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Center(child: Text('$assetName',overflow: TextOverflow.ellipsis,)),
                        const SizedBox(height: 5),
                        Text('Owner: $ownership',overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Text('Valuator:'),
                            const SizedBox(width: 10),
                            Container(
                              height: 15,
                              width: 100,
                              padding: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: const Color.fromARGB(255, 207, 209, 214),
                              ),
                              child: Center(child: Text(
                                validator)), // Display the validator name or fallback
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text("Status: "),
                            SizedBox(width: 10),
                            Container(
                              height: 18,
                              width: 100,
                              padding: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: data['status'] =='Valuated'?Colors.green:Colors.amber),
                              child: Center(child: Text(' ${data['status']}')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 30,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: const LinearGradient(colors: [
                              Colors.lightGreen,
                              Colors.greenAccent
                            ]),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to detailed asset page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                     role =='Assetowner'? 
                                     AssetOwnerDetailPage(assetId: docId, owner:assetowner):
                                     AssetValuatorDetailPage(assetId: docId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.transparent),
                            child: const Text(
                              "View Detail",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}