import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/validated_data_model.dart';

class ValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'validations';

  // Create or update validation
  Future<String?> createValidation(ValidatedDataModel validation) async {
    try {
      print('Starting validation creation/update process...');

      // If we have an ID, check if document exists
      if (validation.id.isNotEmpty) {
        final docRef = _firestore.collection(_collection).doc(validation.id);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          print('Updating existing validation: ${validation.id}');
          await docRef.update({
            ...validation.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return validation.id;
        }
      }

      // Create new document
      final docRef = _firestore.collection(_collection).doc();
      final data = {
        ...validation.toMap(),
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Creating new validation with ID: ${docRef.id}');
      await docRef.set(data);
      return docRef.id;
    } catch (e, stackTrace) {
      print('Error in createValidation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Update validation with safety check
  Future<String?> updateValidation(
      String id, Map<String, dynamic> updates) async {
    try {
      print('Starting validation update process for ID: $id');
      final docRef = _firestore.collection(_collection).doc(id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        print('Updating existing validation');
        await docRef.update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return id;
      } else {
        print('Document not found, creating new one');
        await docRef.set({
          ...updates,
          'id': id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return id;
      }
    } catch (e, stackTrace) {
      print('Error in updateValidation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Get all validations with real-time updates
  Stream<List<ValidatedDataModel>> getValidations() {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ValidatedDataModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error in getValidations stream: $e');
      return Stream.value([]);
    }
  }

  // Get single validation
  Future<ValidatedDataModel?> getValidation(String id) async {
    try {
      print('Fetching validation with ID: $id');
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();

      if (docSnapshot.exists) {
        return ValidatedDataModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      } else {
        print('No validation found with ID: $id');
        return null;
      }
    } catch (e, stackTrace) {
      print('Error in getValidation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Perform revaluation
  Future<String?> createRevaluation(
      String originalId, double memlcFactor, double currencyFactor) async {
    try {
      print('Starting revaluation process for ID: $originalId');
      final original = await getValidation(originalId);

      if (original == null) {
        print('Original validation not found');
        return null;
      }

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
        valuationStatus: 'Revaluation',
        valuationDate: DateTime.now(),
        memlcFactor: memlcFactor,
        currencyFactor: currencyFactor,
        totalCostAfterRevaluation:
            original.totalCostBuilding! * memlcFactor * currencyFactor,
        assetInfo: original.assetInfo,
        landArea: original.landArea,
        landUnitRate: original.landUnitRate,
        selectedValuMethod: original.selectedValuMethod,
        exchangeRates: original.exchangeRates,
      );

      return await createValidation(revaluation);
    } catch (e, stackTrace) {
      print('Error in createRevaluation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Get validations by asset
  Stream<List<ValidatedDataModel>> getValidationsByAsset(String assetName) {
    try {
      return _firestore
          .collection(_collection)
          .where('name', isEqualTo: assetName)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ValidatedDataModel.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error in getValidationsByAsset stream: $e');
      return Stream.value([]);
    }
  }

  // Delete validation
  Future<bool> deleteValidation(String id) async {
    try {
      print('Deleting validation with ID: $id');
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e, stackTrace) {
      print('Error in deleteValidation: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Get all validations for list
  Future<List<ValidatedDataModel>> getAllValidationsForList() async {
    try {
      print('Fetching all validations for list');
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ValidatedDataModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, stackTrace) {
      print('Error in getAllValidationsForList: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get latest validation for an asset
  Future<ValidatedDataModel?> getLatestValidation(String assetName) async {
    try {
      print('Fetching latest validation for asset: $assetName');
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: assetName)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ValidatedDataModel.fromMap(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      print('No validation found for asset: $assetName');
      return null;
    } catch (e, stackTrace) {
      print('Error in getLatestValidation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Helper method to check if document exists
  Future<bool> documentExists(String id) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collection).doc(id).get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking document existence: $e');
      return false;
    }
  }
}
