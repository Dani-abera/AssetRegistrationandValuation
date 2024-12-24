import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssetDetailPage extends StatelessWidget {
  final String assetId;
  const AssetDetailPage({Key? key, required this.assetId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asset Valuations')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('assets')
            .doc(assetId)
            .collection('valuations')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final valuations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: valuations.length,
            itemBuilder: (context, index) {
              final valuation = valuations[index];
              return ListTile(
                title: Text(valuation['valuatorName']),
                subtitle: Text(
                    'Method: ${valuation['valuationMethod']} - \$${valuation['valuationAmount']}'),
                trailing: Icon(Icons.arrow_forward),
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
