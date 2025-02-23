import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef FirestoreQuerySnapshot = QuerySnapshot<Map<String, dynamic>>;

final notificationProvider = StreamProvider.autoDispose
    .family<FirestoreQuerySnapshot, String>((ref, owner) {
  return FirebaseFirestore.instance
      .collection('valuation-report')
      .where('to', isEqualTo: owner)
      .snapshots();
});