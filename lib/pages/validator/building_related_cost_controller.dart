import 'package:flutter/material.dart';

import '../../model/validated_data_model.dart';

class BuildingRelatedCostController {
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  BuildingRelatedCostController();

  factory BuildingRelatedCostController.fromCost(BuildingRelatedCost cost) {
    final controller = BuildingRelatedCostController();
    controller.descriptionController.text = cost.description;
    controller.amountController.text = cost.amount.toString();
    return controller;
  }

  double calculateAmount() {
    return double.tryParse(amountController.text) ?? 0;
  }

  BuildingRelatedCost toBuildingRelatedCost() {
    return BuildingRelatedCost(
      description: descriptionController.text,
      amount: calculateAmount(),
    );
  }

  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
  }
}
