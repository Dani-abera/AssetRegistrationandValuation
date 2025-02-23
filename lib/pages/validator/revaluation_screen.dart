import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../../API/fetch_exchange_rate.dart';

import '../../model/validated_data_model.dart';
import '../../services/revaluation_report_service.dart';
import '../../services/validation_data_service.dart';
import '../../service_locator.dart';

class RevaluationScreen extends StatefulWidget {
  final ValidatedDataModel previousValidation;

  const RevaluationScreen({
    Key? key,
    required this.previousValidation,
  }) : super(key: key);

  @override
  State<RevaluationScreen> createState() => _RevaluationScreenState();
}

class _RevaluationScreenState extends State<RevaluationScreen> {
  final _validationService = getIt<ValidationService>();
  final _formKey = GlobalKey<FormState>();
  final _memlcFactorController = TextEditingController(text: '1.0');

  bool _isLoading = true;
  Map<String, double>? _currentExchangeRates;
  double _exchangeRateFactor = 1.0;
  double _totalRevaluationFactor = 1.0;

  final _dateFormat = DateFormat('dd MMM yyyy');
  final _currencyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    setState(() => _isLoading = true);
    try {
      final currentRates = await FetchExchangeRate.getExchangeRates();
      if (currentRates != null) {
        setState(() {
          _currentExchangeRates = currentRates;
          _calculateExchangeRateFactor();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exchange rates: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateExchangeRateFactor() {
    if (_currentExchangeRates != null &&
        widget.previousValidation.exchangeRates != null) {
      try {
        double previousUsdRate =
            widget.previousValidation.exchangeRates!['ETB']! /
                widget.previousValidation.exchangeRates!['USD']!;
        double currentUsdRate =
            _currentExchangeRates!['ETB']! / _currentExchangeRates!['USD']!;
        _exchangeRateFactor = currentUsdRate / previousUsdRate;
      } catch (e) {
        print('Error calculating exchange rate factor: $e');
        _exchangeRateFactor = 1.0;
      }
    }
    _calculateTotalFactor();
  }

  void _calculateTotalFactor() {
    double memlcFactor = double.tryParse(_memlcFactorController.text) ?? 1.0;
    setState(() {
      _totalRevaluationFactor = memlcFactor * _exchangeRateFactor;
    });
  }

  Future<void> _submitRevaluation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final originalCost = widget.previousValidation.assetType == 'Land'
          ? (widget.previousValidation.landArea ?? 0.0) *
              (widget.previousValidation.landUnitRate ?? 0.0)
          : widget.previousValidation.totalCostBuilding ?? 0.0;

      // Create the new validation object
      final newValidation = ValidatedDataModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: widget.previousValidation.name,
        valuatorName: widget.previousValidation.valuatorName,
        valuationExecutor: widget.previousValidation.valuationExecutor,
        assetType: widget.previousValidation.assetType,
        valuationMethod: widget.previousValidation.valuationMethod,
        constructionCosts: widget.previousValidation.constructionCosts,
        buildingRelatedCosts: widget.previousValidation.buildingRelatedCosts,
        totalCostBuildingConstruction:
            widget.previousValidation.totalCostBuildingConstruction,
        totalBuildingRelatedCost:
            widget.previousValidation.totalBuildingRelatedCost,
        totalCostBuilding: originalCost,
        valuationStatus: 'Revaluation',
        valuationDate: DateTime.now(),
        memlcFactor: double.parse(_memlcFactorController.text),
        currencyFactor: _exchangeRateFactor,
        totalCostAfterRevaluation: originalCost * _totalRevaluationFactor,
        exchangeRates: _currentExchangeRates,
        assetInfo: widget.previousValidation.assetInfo,
        landArea: widget.previousValidation.landArea,
        landUnitRate: widget.previousValidation.landUnitRate,
        selectedValuMethod: widget.previousValidation.selectedValuMethod,
      );

      // Save the new validation
      await _validationService.createValidation(newValidation);

      // Generate report after successful save
      await _generateReport(newValidation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revaluation saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving revaluation: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateReport(ValidatedDataModel newValidation) async {
    try {
      final file = await RevaluationReportService.generateRevaluationReport(
        previousValidation: widget.previousValidation,
        newValidation: newValidation,
        currentExchangeRates: _currentExchangeRates!,
        exchangeRateFactor: _exchangeRateFactor,
        totalRevaluationFactor: _totalRevaluationFactor,
      );

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
                      content: Text('Error opening file: ${result.message}'),
                    ),
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
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revalue Asset'),
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
                    _buildPreviousValidationInfo(),
                    const SizedBox(height: 24),
                    _buildExchangeRateInfo(),
                    const SizedBox(height: 24),
                    _buildRevaluationFactors(),
                    const SizedBox(height: 24),
                    _buildTotalCost(),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitRevaluation,
                        child: const Text(
                            'Submit and Generate Report Revaluation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreviousValidationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previous Validation Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Asset Name', widget.previousValidation.name),
            _buildInfoRow('Asset Type', widget.previousValidation.assetType),
            _buildInfoRow('Validation Date',
                _dateFormat.format(widget.previousValidation.valuationDate)),
            _buildInfoRow('Original Cost',
                'ETB ${_currencyFormat.format(widget.previousValidation.totalCostBuilding)}'),
            _buildInfoRow(
                'Valuation Method', widget.previousValidation.valuationMethod),
            _buildInfoRow('Valuator', widget.previousValidation.valuatorName),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRateInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exchange Rate Factor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildExchangeRateTable(),
            const Divider(height: 32),
            _buildInfoRow(
                'Exchange Rate Factor', _exchangeRateFactor.toStringAsFixed(4),
                isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeRateTable() {
    return Table(
      border: TableBorder.all(),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow(
          ['Currency', 'Previous Rate', 'Current Rate'],
          isHeader: true,
        ),
        ..._buildExchangeRateRows(),
      ],
    );
  }

  List<TableRow> _buildExchangeRateRows() {
    final List<TableRow> rows = [];
    final previousRates = widget.previousValidation.exchangeRates;
    final currentRates = _currentExchangeRates;

    if (previousRates != null && currentRates != null) {
      for (String currency in ['USD', 'EUR', 'GBP', 'AED']) {
        if (previousRates.containsKey(currency) &&
            currentRates.containsKey(currency)) {
          rows.add(_buildTableRow([
            currency,
            previousRates[currency]!.toStringAsFixed(4),
            currentRates[currency]!.toStringAsFixed(4),
          ]));
        }
      }
    }

    return rows;
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells
          .map((cell) => Container(
                padding: const EdgeInsets.all(8),
                color: isHeader ? Colors.grey[200] : null,
                child: Text(
                  cell,
                  style: isHeader
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
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
            TextFormField(
              controller: _memlcFactorController,
              decoration: const InputDecoration(
                labelText: 'MEMLC Factor',
                helperText: 'Market & Economic Movement Local Currency Factor',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter MEMLC factor';
                }
                final number = double.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
              onChanged: (value) => _calculateTotalFactor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCost() {
    final originalCost = widget.previousValidation.totalCostBuilding ?? 0.0;
    final newCost = originalCost * _totalRevaluationFactor;

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
            _buildInfoRow(
                'Original Cost', 'ETB ${_currencyFormat.format(originalCost)}'),
            _buildInfoRow('MEMLC Factor', _memlcFactorController.text),
            _buildInfoRow(
                'Exchange Rate Factor', _exchangeRateFactor.toStringAsFixed(4)),
            _buildInfoRow('Total Revaluation Factor',
                _totalRevaluationFactor.toStringAsFixed(4)),
            const Divider(height: 32),
            _buildInfoRow(
              'New Cost After Revaluation',
              'ETB ${_currencyFormat.format(newCost)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memlcFactorController.dispose();
    super.dispose();
  }
}
