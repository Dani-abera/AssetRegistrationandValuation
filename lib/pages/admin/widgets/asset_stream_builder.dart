import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssetStream extends StatelessWidget {
  final Widget Function(List<QueryDocumentSnapshot>, BuildContext) builder;

  const AssetStream({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('assets')
          .orderBy('timestamp', descending: true) // Order by timestamp, newest first
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
          return const Center(child: Text('No assets found'));
        }

        return builder(assets, context);
      },
    );
  }
}
