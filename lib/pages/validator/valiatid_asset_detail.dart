import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssetDetailPage extends StatelessWidget {
  final String assetId;
  
  const AssetDetailPage({
    super.key, 
    required this.assetId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Valuations')
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('assets')
            .doc(assetId)
            .collection('valuations')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final valuations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: valuations.length,
            itemBuilder: (context, index) {
              final valuation = valuations[index];
              return ListTile(
                title: Text(valuation['valuatorName']),
                subtitle: Text(
                  'Method: ${valuation['valuationMethod']} - \$${valuation['valuationAmount']}'
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to detailed valuation page
                },
              );
            },
          );
        },
      ),
    );
  }
}
