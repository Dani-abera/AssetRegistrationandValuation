import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:land_house_verify/pages/admin/asset_detail_page.dart';

class LatestAssetsPage extends StatelessWidget {
  const LatestAssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('assets')
          .orderBy('createdAt', descending: true) // Order by timestamp
          .limit(3) // Fetch only the latest three
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
          return const Center(child: Text('No assets available.'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final data = assets[index].data() as Map<String, dynamic>;
            final assetImage = (data['assetImage'] as List?)?.first ?? '';
            debugPrint(assetImage);
            final assetName = data['assetName'] ?? 'Unknown Asset';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssetDetailPage(assetId: assets[index].id),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        assetImage,

                        height: 170,
                        width: 300,
                        fit: BoxFit.fill,
                        errorBuilder: (_, __, ___) => Container(
                          height: 100,
                          width: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('Image not available'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0 , vertical: 4.0),
                      child: Text(
                        assetName,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
