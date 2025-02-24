import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:land_house_verify/pages/admin/add_rooms.dart';
import 'package:open_file/open_file.dart';
import '../../API/fetch_exchange_rate.dart';
import '../../model/validated_data_model.dart';
import 'package:uuid/uuid.dart';
import '../../service_locator.dart';
import '../../services/report_service.dart';
import '../../services/validation_data_service.dart';
import 'building_related_cost_controller.dart';
import 'construction_cost_controller.dart';

class ValidationInputScreen extends StatefulWidget {
  final String? assetId; // Optional - for editing existing validation
  final Map<String, dynamic>? assetInfo;

  const ValidationInputScreen({super.key, this.assetId, this.assetInfo});

  @override
  State<ValidationInputScreen> createState() => _ValidationInputScreenState();
}

class _ValidationInputScreenState extends State<ValidationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _validationService = getIt<ValidationService>();
  bool _isLoading = false;
  Map<String, double>? _exchangeRates;
  final List<String> _currencyList = ['USD', 'AUD', 'CAD', 'AED'];

  // Add these to your state class
  final _landAreaController = TextEditingController();
  final _landUnitRateController = TextEditingController();
  String _selectedValuMethod = 'Lease Office Value'; // Default value
  double? _previousValidationAmount;

// Add land grade options
  final List<String> _valueMethode = [
    'Lease Office Value',
    'Local Broker',
    'Price Of a Similar Land In The Area',
  ];

  // Controllers for basic information
  final _nameController = TextEditingController();
  final _valuatorNameController = TextEditingController();
  final _valuationExecutorController = TextEditingController();
  final _summaryController = TextEditingController();

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
    _initializeData();
    _addInitialCosts();
    _loadExistingData();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    final rates = await FetchExchangeRate.getExchangeRates();
    if (rates != null) {
      print('Fetched exchange rates: $rates'); // Debug print
      setState(() {
        _exchangeRates = rates;
      });
    }
  }

  void _initializeData() {
    if (widget.assetInfo != null) {
      // Set values from assetInfo if available
      _nameController.text = widget.assetInfo!['assetName'] ?? '';
      // _valuatorNameController.text =
      //     widget.assetInfo!['assignedValidator'] ?? '';
      _selectedAssetType = widget.assetInfo!['assetType'] ?? 'Land';

      // Additional asset info that might be useful
      _valuationExecutorController.text = widget.assetInfo!['ownership'] ?? '';

      // You might want to add these to the form display
      //final location = widget.assetInfo!['location'] ?? '';
      //final titleDeedNumber = widget.assetInfo!['titleDeedNumber'] ?? '';
      //  final createdAt = widget.assetInfo!['createdAt'];
      // final DateTime createdDateTime =
      //  createdAt is Timestamp ? createdAt.toDate() : DateTime.now();
      _summaryController.text = widget.assetInfo!['summary'] ?? '';
    } else {
      // Set default values when no asset info is provided
      _nameController.text = '';
      _valuatorNameController.text = '';
      _valuationExecutorController.text = '';
      _selectedAssetType = 'Land';
      _summaryController.text = '';
    }
  }

  void _addInitialCosts() {
    // Add initial empty construction cost
    var constructionCostController = ConstructionCostController();

    // Only set description if assetInfo exists
    if (widget.assetInfo != null) {
      // constructionCostController.descriptionController.text =
      //     widget.assetInfo!['description'] ?? '';
      constructionCostController.areaController.text =
          widget.assetInfo!['area'] ?? '';
    }
    _constructionCosts.add(constructionCostController);

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

  Future<bool> _checkPreviousValidation() async {
    try {
      final previousValidation =
          await _validationService.getLatestValidation(widget.assetId!);
      if (previousValidation != null) {
        setState(() {
          _previousValidationAmount = previousValidation.totalCostBuilding;
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error checking previous validation: $e');
      return false;
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
      // Calculate total cost
      double totalCost = _selectedAssetType == 'Land'
          ? (double.tryParse(_landAreaController.text) ?? 0) *
              (double.tryParse(_landUnitRateController.text) ?? 0)
          : _calculateTotalCost();

      final validation = ValidatedDataModel(
        id: widget.assetId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        valuatorName: _valuatorNameController.text,
        valuationExecutor: _valuationExecutorController.text,
        assetType: _selectedAssetType,
        valuationMethod: _selectedValuMethod,
        constructionCosts:
            _constructionCosts.map((c) => c.toConstructionCost()).toList(),
        buildingRelatedCosts: _buildingRelatedCosts
            .map((c) => c.toBuildingRelatedCost())
            .toList(),
        totalCostBuildingConstruction: _calculateTotalConstructionCost(),
        totalBuildingRelatedCost: _calculateTotalRelatedCost(),
        totalCostBuilding: totalCost,
        valuationStatus: _valuationStatus,
        valuationDate: DateTime.now(),
        memlcFactor: double.tryParse(_memlcFactorController.text) ?? 1.0,
        currencyFactor: double.tryParse(_currencyFactorController.text) ?? 1.0,
        totalCostAfterRevaluation: _calculateTotalCostAfterRevaluation(),
        assetInfo: widget.assetInfo,
        landArea: double.tryParse(_landAreaController.text),
        landUnitRate: double.tryParse(_landUnitRateController.text),
        selectedValuMethod: _selectedValuMethod,
        exchangeRates: _exchangeRates,
        summary: _summaryController.text,
      );

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
      floatingActionButton: SizedBox(
        height: 100,
        child: ElevatedButton(
          onPressed: () {
            var uuid = Uuid();
            String randomId = uuid.v4(); // Generate a new random ID
            String newId = '${widget.assetId}/$randomId';
            // Ensure assetId is not null and provide a valid id for AddRoomsPage
            if (widget.assetId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddRoomsPage(
                    assetId: widget.assetId!,
                    id: newId, // Assuming you want to pass the assetId
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Asset ID is required to add rooms.')),
              );
            }
          },
          child: const Text('Add Single Room'),
        ),
      ),
      appBar: AppBar(
        title:
            Text(widget.assetId != null ? 'Edit Validation' : 'New Validation'),
        actions: [
          if (widget.assetId != null)
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

                    // Show different forms based on asset type
                    if (_selectedAssetType == 'Land')
                      _buildLandValuationForm()
                    else
                      Column(
                        children: [
                          _buildConstructionCostsSection(),
                          const SizedBox(height: 24),
                          _buildBuildingRelatedCostsSection(),
                        ],
                      ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _summaryController,
                      decoration: const InputDecoration(
                        labelText: 'Assumptions of Asset Valuation',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter a summary'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    if (_valuationStatus == 'Revaluation')
                      _buildRevaluationFactors(),
                    const SizedBox(height: 32),

                    _buildTotalCostDisplay(),
                    const SizedBox(height: 18),

                    const SizedBox(height: 32),
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
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLandValuationForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Land Valuation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _landAreaController,
              decoration: const InputDecoration(
                labelText: 'Land Area (m²)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter land area';
                if (double.tryParse(value!) == null) {
                  return 'Please enter valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedValuMethod,
              decoration: const InputDecoration(
                labelText: 'Land Grade',
                border: OutlineInputBorder(),
              ),
              items: _valueMethode
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedValuMethod = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _landUnitRateController,
              decoration: const InputDecoration(
                labelText: 'Unit Rate (per m²)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter unit rate';
                if (double.tryParse(value!) == null) {
                  return 'Please enter valid number';
                }
                return null;
              },
            ),
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
            }),
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
            // Display asset info if available
            if (widget.assetInfo != null) ...[
              _buildInfoRow('Location', widget.assetInfo!['location'] ?? ''),
              _buildInfoRow(
                  'Title Deed', widget.assetInfo!['titleDeedNumber'] ?? ''),
              _buildInfoRow('Owner', widget.assetInfo!['ownership'] ?? ''),
              if (widget.assetInfo!['createdAt'] != null)
                _buildInfoRow(
                  'Created At',
                  DateFormat('dd MMM yyyy').format(
                    (widget.assetInfo!['createdAt'] as Timestamp).toDate(),
                  ),
                ),
              const Divider(),
            ],
            // Rest of your existing form fields
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
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

  double _calculateTotalCost() {
    if (_selectedAssetType == 'Land') {
      final area = double.tryParse(_landAreaController.text) ?? 0;
      final unitRate = double.tryParse(_landUnitRateController.text) ?? 0;
      return area * unitRate;
    } else {
      return _calculateTotalConstructionCost() + _calculateTotalRelatedCost();
    }
  }

  Widget _buildTotalCostDisplay() {
    final totalCost = _calculateTotalCost();
    final totalAfterRevaluation = _valuationStatus == 'Revaluation'
        ? totalCost *
            double.parse(_memlcFactorController.text) *
            double.parse(_currencyFactorController.text)
        : totalCost;

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
            if (_previousValidationAmount != null &&
                _valuationStatus == 'Revaluation')
              Text(
                  'Previous Validation Amount: \$${_previousValidationAmount!.toStringAsFixed(2)}'),
            Text('Total Cost: \$${totalCost.toStringAsFixed(2)}'),
            if (_valuationStatus == 'Revaluation')
              Text(
                  'Total After Revaluation: \$${totalAfterRevaluation.toStringAsFixed(2)}'),
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
    // 1. Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Check revaluation requirements
    if (_valuationStatus == 'Revaluation') {
      final hasPreValidation = await _checkPreviousValidation();
      if (!hasPreValidation) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asset must be validated first before revaluation'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // 3. Check exchange rates
    if (_exchangeRates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch exchange rates. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4. Start loading
    setState(() => _isLoading = true);

    try {
      // 5. Calculate costs
      final totalCost = _selectedAssetType == 'Land'
          ? (double.tryParse(_landAreaController.text) ?? 0) *
              (double.tryParse(_landUnitRateController.text) ?? 0)
          : _calculateTotalConstructionCost() + _calculateTotalRelatedCost();

      // 6. Convert exchange rates
      final convertedRates = Map<String, double>.from(_exchangeRates!);

      // 7. Create validation model
      final validation = ValidatedDataModel(
        id: widget.assetId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        valuatorName: _valuatorNameController.text.trim(),
        valuationExecutor: _valuationExecutorController.text.trim(),
        assetType: _selectedAssetType,
        valuationMethod: _selectedValuMethod,
        constructionCosts: _constructionCosts
            .map((c) => ConstructionCost(
                  description: c.descriptionController.text.trim(),
                  areaInM2: double.tryParse(c.areaController.text) ?? 0,
                  numberOfTypicalBuildings:
                      int.tryParse(c.numberOfBuildingsController.text) ?? 0,
                  unitRate: double.tryParse(c.unitRateController.text) ?? 0,
                  amount: c.calculateAmount(),
                ))
            .toList(),
        buildingRelatedCosts: _buildingRelatedCosts
            .map((c) => BuildingRelatedCost(
                  description: c.descriptionController.text.trim(),
                  amount: double.tryParse(c.amountController.text) ?? 0,
                ))
            .toList(),
        totalCostBuildingConstruction: _calculateTotalConstructionCost(),
        totalBuildingRelatedCost: _calculateTotalRelatedCost(),
        totalCostBuilding: totalCost,
        valuationStatus: _valuationStatus,
        valuationDate: DateTime.now(),
        memlcFactor: double.tryParse(_memlcFactorController.text) ?? 1.0,
        currencyFactor: double.tryParse(_currencyFactorController.text) ?? 1.0,
        totalCostAfterRevaluation: _calculateTotalCostAfterRevaluation(),
        assetInfo: widget.assetInfo,
        landArea: double.tryParse(_landAreaController.text),
        landUnitRate: double.tryParse(_landUnitRateController.text),
        selectedValuMethod: _selectedValuMethod,
        exchangeRates: convertedRates,
      );

      // 8. Save validation
      String? result;
      if (widget.assetId != null && widget.assetId!.isNotEmpty) {
        print('Updating validation: ${widget.assetId}');
        result = await _validationService.updateValidation(
          widget.assetId!,
          validation.toMap(),
        );
      } else {
        print('Creating new validation');
        result = await _validationService.createValidation(validation);
      }

      // 9. Handle result
      if (!mounted) return;

      if (result != null) {
        print('Validation saved successfully with ID: $result');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Validation saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to save validation: no result returned');
      }
    } catch (e, stackTrace) {
      // 11. Error handling
      print('Error saving validation: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      // 12. Reset loading state
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
    _summaryController.dispose();
    super.dispose();
  }
}
