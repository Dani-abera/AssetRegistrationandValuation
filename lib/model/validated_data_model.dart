// Asset Model
class ValidatedDataModel {
  final String name;
  final String valuatorName;
  final String valuationExecutor;
  final String assetType;
  final String valuationMethod;
  final List<ConstructionCost> constructionCosts;
  final List<BuildingRelatedCost> buildingRelatedCosts;
  final double totalCostBuildingConstruction;
  final double totalBuildingRelatedCost;
  final double totalCostBuilding;
  final String valuationStatus;
  final DateTime valuationDate;
  final double memlcFactor;
  final double currencyFactor;
  final double totalCostAfterRevaluation;

  ValidatedDataModel({
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
  });

  // Method to calculate the total building cost (including construction and related costs)
  double getTotalCost() {
    return totalCostBuildingConstruction + totalBuildingRelatedCost;
  }

  // Method to calculate the revalued cost of the building
  double getRevaluedCost() {
    double result1 = memlcFactor * totalCostBuilding;
    return result1 * currencyFactor;
  }
}

// Construction Cost Model
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
}

// Building Related Cost Model
class BuildingRelatedCost {
  final String description;
  final double amount;

  BuildingRelatedCost({
    required this.description,
    required this.amount,
  });
}
