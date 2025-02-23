import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:land_house_verify/pages/admin/asset_detail_page.dart';



class AllAssetsPage extends StatelessWidget {

  const AllAssetsPage({super.key, });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('assets').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading assets'));
        }

        final assets = snapshot.data?.docs ?? [];

        if (assets.isEmpty) {
          return const Center(child: Text('No assets found'));
        }

        return Expanded(
          child: ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final data = assets[index].data() as Map<String, dynamic>;
              final docId = assets[index].id;
              final assetImage = (data['assetImage'] as List?)?.first ?? '';
              final assetName = data['assetName'] ?? 'Unknown Asset';
              final ownership = data['ownership'] ?? 'Unknown Owner';
              final validator = data['validator'] ?? 'Not Assigned';
              final status = data['status'] ?? 'Unknown Status';

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AssetDetailPage(assetId: docId),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          assetImage,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Image not available'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Asset Name: $assetName'),
                    Text('Asset Owner: $ownership'),
                    Text('Validator: $validator'),
                    Text('Status: $status'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssetDetailPage(assetId: docId)
                            ),
                          );
                        },
                        child: const Text(
                          "View Detail",
                          style: TextStyle(
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
    );
  }
}
