import 'package:flutter/material.dart';
import 'package:land_house_verify/service_locator.dart';

import '../../model/validated_data_model.dart';
import '../../services/validation_data_service.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final _validationService = getIt<ValidationService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ValidatedDataModel>>(
      stream: _validationService.getValidations(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final validations = snapshot.data!;
        return ListView.builder(
          itemCount: validations.length,
          itemBuilder: (context, index) {
            final validation = validations[index];
            return ListTile(
                title: Text(validation.name),
                subtitle: Text('Total Cost: ${validation.totalCostBuilding}'),
                trailing: Text(validation.valuationStatus),
                onTap: () {});
          },
        );
      },
    );
  }
}
