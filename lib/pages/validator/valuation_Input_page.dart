import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import '../../model/validated_data_model.dart';
import '../../service_locator.dart';
import '../../services/report_service.dart';
import '../../services/validation_data_service.dart';
import 'building_related_cost_controller.dart';
import 'construction_cost_controller.dart';

class ValidationInputScreen extends StatefulWidget {
  final String? assetId; // Optional - for editing existing validation

  const ValidationInputScreen({super.key, this.assetId});

  @override
  State<ValidationInputScreen> createState() => _ValidationInputScreenState();
}

class _ValidationInputScreenState extends State<ValidationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _validationService = getIt<ValidationService>();
  bool _isLoading = false;

  // Controllers for basic information
  final _nameController = TextEditingController();
  final _valuatorNameController = TextEditingController();
  final _valuationExecutorController = TextEditingController();

  // Lists for dynamic costs
  final List<ConstructionCostController> _constructionCosts = [];
  final List<BuildingRelatedCostController> _buildingRelatedCosts = [];

  // Dropdown values
  String _selectedAssetType = 'Land';
  String _selectedValuationMethod = 'Market Approach';
  String _valuationStatus = 'First Valuation';

  // Revaluation factors
  final _memlcFactorController = TextEditingController(text: '1.0');
  final _currencyFactorController = TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _addInitialCosts();
    _loadExistingData();
  }

  void _addInitialCosts() {
    // Add initial empty construction cost
    _constructionCosts.add(ConstructionCostController());
    // Add initial empty building related cost
    _buildingRelatedCosts.add(BuildingRelatedCostController());
  }

  Future<void> _loadExistingData() async {
    if (widget.assetId != null) {
      setState(() => _isLoading = true);
      try {
        final validation =
            await _validationService.getValidation(widget.assetId!);
        if (validation != null) {
          _populateForm(validation);
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateForm(ValidatedDataModel validation) {
    _nameController.text = validation.name;
    _valuatorNameController.text = validation.valuatorName;
    _valuationExecutorController.text = validation.valuationExecutor;
    _selectedAssetType = validation.assetType;
    _selectedValuationMethod = validation.valuationMethod;
    _valuationStatus = validation.valuationStatus;

    // Clear and populate construction costs
    _constructionCosts.clear();
    for (var cost in validation.constructionCosts) {
      _constructionCosts.add(ConstructionCostController.fromCost(cost));
    }

    // Clear and populate building related costs
    _buildingRelatedCosts.clear();
    for (var cost in validation.buildingRelatedCosts) {
      _buildingRelatedCosts.add(BuildingRelatedCostController.fromCost(cost));
    }

    setState(() {});
  }

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create validation object using your existing form data
      final validation = ValidatedDataModel(
        id: widget.assetId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        valuatorName: _valuatorNameController.text,
        valuationExecutor: _valuationExecutorController.text,
        assetType: _selectedAssetType,
        valuationMethod: _selectedValuationMethod,
        constructionCosts:
            _constructionCosts.map((c) => c.toConstructionCost()).toList(),
        buildingRelatedCosts: _buildingRelatedCosts
            .map((c) => c.toBuildingRelatedCost())
            .toList(),
        totalCostBuildingConstruction: _calculateTotalConstructionCost(),
        totalBuildingRelatedCost: _calculateTotalRelatedCost(),
        totalCostBuilding:
            _calculateTotalConstructionCost() + _calculateTotalRelatedCost(),
        valuationStatus: _valuationStatus,
        valuationDate: DateTime.now(),
        memlcFactor: double.parse(_memlcFactorController.text),
        currencyFactor: double.parse(_currencyFactorController.text),
        totalCostAfterRevaluation: _calculateTotalCostAfterRevaluation(),
      );

      // Generate and save the report
      final reportService = getIt<ReportService>();
      final file = await reportService.generateValidationReport(validation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report saved to: ${file.path}'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                final result = await OpenFile.open(file.path);
                if (result.type != ResultType.done) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error opening file: ${result.message}')),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.assetId != null ? 'Edit Validation' : 'New Validation'),
        actions: [
          if (widget.assetId != null) // Only show for existing validations
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generateReport,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitValidation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInformation(),
                    const SizedBox(height: 24),
                    _buildConstructionCostsSection(),
                    const SizedBox(height: 24),
                    _buildBuildingRelatedCostsSection(),
                    const SizedBox(height: 24),
                    if (_valuationStatus == 'Revaluation')
                      _buildRevaluationFactors(),
                    const SizedBox(height: 32),
                    _buildTotalCostDisplay(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConstructionCostsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Construction Costs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _constructionCosts.add(ConstructionCostController());
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._constructionCosts.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item ${index + 1}'),
                            if (_constructionCosts.length > 1)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _constructionCosts.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter description'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.areaController,
                                decoration: const InputDecoration(
                                  labelText: 'Area (m²)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter area';
                                  }
                                  if (double.tryParse(value!) == null) {
                                    return 'Please enter valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller:
                                    controller.numberOfBuildingsController,
                                decoration: const InputDecoration(
                                  labelText: 'Number of Buildings',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Please enter number';
                                  }
                                  if (int.tryParse(value!) == null) {
                                    return 'Please enter valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.unitRateController,
                          decoration: const InputDecoration(
                            labelText: 'Unit Rate',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter unit rate';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Please enter valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount: ${controller.calculateAmount().toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingRelatedCostsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Building Related Costs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _buildingRelatedCosts
                          .add(BuildingRelatedCostController());
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildingRelatedCosts.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Item ${index + 1}'),
                            if (_buildingRelatedCosts.length > 1)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _buildingRelatedCosts.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter description'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller.amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Please enter valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Asset Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter asset name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valuatorNameController,
              decoration: const InputDecoration(
                labelText: 'Valuator Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter valuator name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAssetType,
              decoration: const InputDecoration(
                labelText: 'Asset Type',
                border: OutlineInputBorder(),
              ),
              items: ['Land', 'House']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAssetType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _valuationStatus,
              decoration: const InputDecoration(
                labelText: 'Valuation Status',
                border: OutlineInputBorder(),
              ),
              items: ['First Valuation', 'Revaluation']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _valuationStatus = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConstructionCostItem(ConstructionCostController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          TextFormField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.areaController,
                  decoration: const InputDecoration(
                    labelText: 'Area (m²)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller.unitRateController,
                  decoration: const InputDecoration(
                    labelText: 'Unit Rate',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevaluationFactors() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revaluation Factors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _memlcFactorController,
                    decoration: const InputDecoration(
                      labelText: 'MEMLC Factor',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _currencyFactorController,
                    decoration: const InputDecoration(
                      labelText: 'Currency Factor',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCostDisplay() {
    final totalConstructionCost = _calculateTotalConstructionCost();
    final totalRelatedCost = _calculateTotalRelatedCost();
    final totalCost = totalConstructionCost + totalRelatedCost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cost Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
                'Total Construction Cost: \$${totalConstructionCost.toStringAsFixed(2)}'),
            Text(
                'Total Related Cost: \$${totalRelatedCost.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'Total Cost: \$${totalCost.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotalConstructionCost() {
    return _constructionCosts.fold(
        0.0, (sum, controller) => sum + controller.calculateAmount());
  }

  double _calculateTotalRelatedCost() {
    return _buildingRelatedCosts.fold(
        0.0, (sum, controller) => sum + controller.calculateAmount());
  }

  Future<void> _submitValidation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final validation = ValidatedDataModel(
        id: widget.assetId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        valuatorName: _valuatorNameController.text,
        valuationExecutor: _valuationExecutorController.text,
        assetType: _selectedAssetType,
        valuationMethod: _selectedValuationMethod,
        constructionCosts:
            _constructionCosts.map((c) => c.toConstructionCost()).toList(),
        buildingRelatedCosts: _buildingRelatedCosts
            .map((c) => c.toBuildingRelatedCost())
            .toList(),
        totalCostBuildingConstruction: _calculateTotalConstructionCost(),
        totalBuildingRelatedCost: _calculateTotalRelatedCost(),
        totalCostBuilding:
            _calculateTotalConstructionCost() + _calculateTotalRelatedCost(),
        valuationStatus: _valuationStatus,
        valuationDate: DateTime.now(),
        memlcFactor: double.parse(_memlcFactorController.text),
        currencyFactor: double.parse(_currencyFactorController.text),
        totalCostAfterRevaluation: _calculateTotalCostAfterRevaluation(),
      );

      final result = widget.assetId != null
          ? await _validationService.updateValidation(
              widget.assetId!, validation.toMap())
          : await _validationService.createValidation(validation);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Validation saved successfully')),
          );
        } else {
          throw Exception('Failed to save validation');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateTotalCostAfterRevaluation() {
    final totalCost =
        _calculateTotalConstructionCost() + _calculateTotalRelatedCost();
    final memlcFactor = double.parse(_memlcFactorController.text);
    final currencyFactor = double.parse(_currencyFactorController.text);
    return totalCost * memlcFactor * currencyFactor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valuatorNameController.dispose();
    _valuationExecutorController.dispose();
    _memlcFactorController.dispose();
    _currencyFactorController.dispose();
    for (var controller in _constructionCosts) {
      controller.dispose();
    }
    for (var controller in _buildingRelatedCosts) {
      controller.dispose();
    }
    super.dispose();
  }
}
