import 'package:flutter/material.dart';

import '../../model/validated_data_model.dart';

class ConstructionCostController {
  final descriptionController = TextEditingController();
  final areaController = TextEditingController();
  final numberOfBuildingsController = TextEditingController(text: '1');
  final unitRateController = TextEditingController();

  ConstructionCostController();

  factory ConstructionCostController.fromCost(ConstructionCost cost) {
    final controller = ConstructionCostController();
    controller.descriptionController.text = cost.description;
    controller.areaController.text = cost.areaInM2.toString();
    controller.numberOfBuildingsController.text =
        cost.numberOfTypicalBuildings.toString();
    controller.unitRateController.text = cost.unitRate.toString();
    return controller;
  }

  double calculateAmount() {
    final area = double.tryParse(areaController.text) ?? 0;
    final buildings = int.tryParse(numberOfBuildingsController.text) ?? 1;
    final rate = double.tryParse(unitRateController.text) ?? 0;
    return area * buildings * rate;
  }

  ConstructionCost toConstructionCost() {
    return ConstructionCost(
      description: descriptionController.text,
      areaInM2: double.tryParse(areaController.text) ?? 0,
      numberOfTypicalBuildings:
          int.tryParse(numberOfBuildingsController.text) ?? 1,
      unitRate: double.tryParse(unitRateController.text) ?? 0,
      amount: calculateAmount(),
    );
  }

  void dispose() {
    descriptionController.dispose();
    areaController.dispose();
    numberOfBuildingsController.dispose();
    unitRateController.dispose();
  }
}
