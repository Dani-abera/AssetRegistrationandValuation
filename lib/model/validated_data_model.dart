import 'package:cloud_firestore/cloud_firestore.dart';

class ValidatedDataModel {
  final String id; // Add ID field
  final String name;
  final String valuatorName;
  final String valuationExecutor;
  final String assetType;
  final String valuationMethod;
  final List<ConstructionCost> constructionCosts;
  final List<BuildingRelatedCost> buildingRelatedCosts;
  final double totalCostBuildingConstruction;
  final double totalBuildingRelatedCost;
  final String valuationStatus;
  final DateTime valuationDate;
  final double memlcFactor;
  final double currencyFactor;
  final double totalCostAfterRevaluation;
  final Map<String, dynamic>? assetInfo;
  final String selectedValuMethod;
  final Map<String, double>? exchangeRates;
  final double? landArea;
  final double? landUnitRate;
  final double? totalCostBuilding;
  final List<String>? imageUrls;
  final String summary;

  ValidatedDataModel({
    required this.id,
    required this.name,
    required this.valuatorName,
    required this.valuationExecutor,
    required this.assetType,
    required this.valuationMethod,
    required this.constructionCosts,
    required this.buildingRelatedCosts,
    required this.totalCostBuildingConstruction,
    required this.totalBuildingRelatedCost,
    required this.totalCostBuilding,
    required this.valuationStatus,
    required this.valuationDate,
    required this.memlcFactor,
    required this.currencyFactor,
    required this.totalCostAfterRevaluation,
    this.assetInfo,
    this.landArea = 0.0,
    this.landUnitRate = 0.0,
    this.selectedValuMethod = '',
    this.exchangeRates,
    this.imageUrls,
    this.summary = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'valuatorName': valuatorName,
      'valuationExecutor': valuationExecutor,
      'assetType': assetType,
      'valuationMethod': valuationMethod,
      'constructionCosts':
          constructionCosts.map((cost) => cost.toMap()).toList(),
      'buildingRelatedCosts':
          buildingRelatedCosts.map((cost) => cost.toMap()).toList(),
      'totalCostBuildingConstruction': totalCostBuildingConstruction,
      'totalBuildingRelatedCost': totalBuildingRelatedCost,
      'totalCostBuilding': totalCostBuilding,
      'valuationStatus': valuationStatus,
      'valuationDate': Timestamp.fromDate(valuationDate),
      'memlcFactor': memlcFactor,
      'currencyFactor': currencyFactor,
      'totalCostAfterRevaluation': totalCostAfterRevaluation,
      'assetInfo': assetInfo,
      'landArea': landArea,
      'landUnitRate': landUnitRate,
      'selectedValuMethod': selectedValuMethod,
      'exchangeRates': exchangeRates,
      'imageUrls': imageUrls ?? [],
      'summary': summary,
    };
  }

  factory ValidatedDataModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    Map<String, double>? convertedRates;
    if (map['exchangeRates'] != null) {
      convertedRates = {};
      (map['exchangeRates'] as Map<String, dynamic>).forEach((key, value) {
        if (value is int) {
          convertedRates![key] = value.toDouble();
        } else if (value is double) {
          convertedRates![key] = value;
        } else {
          convertedRates![key] = double.tryParse(value.toString()) ?? 0.0;
        }
      });
    }
    return ValidatedDataModel(
      id: documentId,
      name: map['name'] ?? '',
      valuatorName: map['valuatorName'] ?? '',
      valuationExecutor: map['valuationExecutor'] ?? '',
      assetType: map['assetType'] ?? '',
      valuationMethod: map['valuationMethod'] ?? '',
      constructionCosts: (map['constructionCosts'] as List<dynamic>)
          .map((cost) => ConstructionCost.fromMap(cost))
          .toList(),
      buildingRelatedCosts: (map['buildingRelatedCosts'] as List<dynamic>)
          .map((cost) => BuildingRelatedCost.fromMap(cost))
          .toList(),
      totalCostBuildingConstruction:
          map['totalCostBuildingConstruction']?.toDouble() ?? 0.0,
      totalBuildingRelatedCost:
          map['totalBuildingRelatedCost']?.toDouble() ?? 0.0,
      totalCostBuilding: map['totalCostBuilding']?.toDouble() ?? 0.0,
      valuationStatus: map['valuationStatus'] ?? '',
      valuationDate: map['valuationDate'] != null
          ? (map['valuationDate'] as Timestamp).toDate()
          : DateTime.now(),
      memlcFactor: map['memlcFactor']?.toDouble() ?? 1.0,
      currencyFactor: map['currencyFactor']?.toDouble() ?? 1.0,
      totalCostAfterRevaluation:
          map['totalCostAfterRevaluation']?.toDouble() ?? 0.0,
      assetInfo: map['assetInfo'] as Map<String, dynamic>?,
      landArea: map['landArea']?.toDouble() ?? 0.0,
      landUnitRate: map['landUnitRate']?.toDouble() ?? 0.0,
      selectedValuMethod: map['selectedValuMethod'] ?? '',
      exchangeRates: convertedRates,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      summary: map['summary'] ?? '',
    );
  }
}

class ConstructionCost {
  final String description;
  final double areaInM2;
  final int numberOfTypicalBuildings;
  final double unitRate;
  final double amount;

  ConstructionCost({
    required this.description,
    required this.areaInM2,
    required this.numberOfTypicalBuildings,
    required this.unitRate,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'areaInM2': areaInM2,
      'numberOfTypicalBuildings': numberOfTypicalBuildings,
      'unitRate': unitRate,
      'amount': amount,
    };
  }

  factory ConstructionCost.fromMap(Map<String, dynamic> map) {
    return ConstructionCost(
      description: map['description'] ?? '',
      areaInM2: map['areaInM2']?.toDouble() ?? 0.0,
      numberOfTypicalBuildings: map['numberOfTypicalBuildings'] ?? 0,
      unitRate: map['unitRate']?.toDouble() ?? 0.0,
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }
}

class BuildingRelatedCost {
  final String description;
  final double amount;

  BuildingRelatedCost({
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
    };
  }

  factory BuildingRelatedCost.fromMap(Map<String, dynamic> map) {
    return BuildingRelatedCost(
      description: map['description'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
    );
  }
}
