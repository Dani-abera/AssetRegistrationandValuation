import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/validated_data_model.dart';

class ValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'validations';

  // Create new validation
  Future<String?> createValidation(ValidatedDataModel validation) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(validation.toMap());
      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get all validations
  Stream<List<ValidatedDataModel>> getValidations() {
    return _firestore
        .collection(_collection)
        .orderBy('valuationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ValidatedDataModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get single validation
  Future<ValidatedDataModel?> getValidation(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ValidatedDataModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update validation
  Future<bool> updateValidation(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(id).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Perform revaluation
  Future<String?> createRevaluation(
      String originalId, double memlcFactor, double currencyFactor) async {
    try {
      final original = await getValidation(originalId);
      if (original == null) return null;

      final revaluation = ValidatedDataModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: original.name,
        valuatorName: original.valuatorName,
        valuationExecutor: original.valuationExecutor,
        assetType: original.assetType,
        valuationMethod: original.valuationMethod,
        constructionCosts: original.constructionCosts,
        buildingRelatedCosts: original.buildingRelatedCosts,
        totalCostBuildingConstruction: original.totalCostBuildingConstruction,
        totalBuildingRelatedCost: original.totalBuildingRelatedCost,
        totalCostBuilding: original.totalCostBuilding,
        valuationStatus: 'revaluation',
        valuationDate: DateTime.now(),
        memlcFactor: memlcFactor,
        currencyFactor: currencyFactor,
        totalCostAfterRevaluation:
            original.totalCostBuilding! * memlcFactor * currencyFactor,
      );

      return await createValidation(revaluation);
    } catch (e) {
      return null;
    }
  }

  // Get validations by asset
  Stream<List<ValidatedDataModel>> getValidationsByAsset(String assetName) {
    return _firestore
        .collection(_collection)
        .where('name', isEqualTo: assetName)
        .orderBy('valuationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ValidatedDataModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Delete validation
  Future<bool> deleteValidation(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ValidatedDataModel>> getAllValidationsForList() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('validations')
          .orderBy('valuationDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ValidatedDataModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting validations: $e');
      return [];
    }
  }

  // Get latest validation for an asset
  Future<ValidatedDataModel?> getLatestValidation(String assetName) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: assetName)
          .orderBy('valuationDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ValidatedDataModel.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
