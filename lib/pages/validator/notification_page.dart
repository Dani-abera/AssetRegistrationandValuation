import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/validator/message_card.dart';

class NotificationPage extends StatelessWidget {
  final String? valuator;
  const NotificationPage({super.key,   this.valuator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification"),),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
          .collection('report_request')
          .where('to', isEqualTo: valuator) // Filter by the current validator's name
          .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
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
          return ListView.builder(
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final data = assets[index].data() as Map<String, dynamic>;
            final from = data['from'] ?? 'Unknown owner';
            final assetName = data['assetName'] ?? 'Unknown Asset Name';
            final message = data['msg'] ?? 'Not msg';

            print(data);
    
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(179, 231, 228, 228),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MessageCard(
                    from: from,
                    assetName: assetName,
                    message:message,
                  ),
                  ],
                ),
              ),
            ),
            );
          },
        );
        }
        ),
    );
    
  }
}