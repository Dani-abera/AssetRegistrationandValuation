import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer.dart';

import 'asset_detail_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('assets').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading assets'));
          }
          final assets = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final data = assets[index].data() as Map<String, dynamic>;
              final docId = assets[index].id;

              return ListTile(
                title: Text(data['assetName']),
                subtitle: Text('Type: ${data['assetType']}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to detailed asset page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetDetailPage(assetId: docId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
