import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/validated_data_model.dart';

import '../../services/validation_data_service.dart';
import '../../service_locator.dart';
import 'revaluation_screen.dart';

class ValidationListScreen extends StatefulWidget {
  const ValidationListScreen({Key? key}) : super(key: key);

  @override
  State<ValidationListScreen> createState() => _ValidationListScreenState();
}

class _ValidationListScreenState extends State<ValidationListScreen> {
  final _validationService = getIt<ValidationService>();
  bool _isLoading = true;
  List<ValidatedDataModel> _validations = [];
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final _dateFormat = DateFormat('dd MMM yyyy');
  final _currencyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _loadValidations();
  }

  Future<void> _loadValidations() async {
    setState(() => _isLoading = true);
    try {
      final validations = await _validationService.getAllValidationsForList();
      setState(() {
        _validations = validations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading validations: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  List<ValidatedDataModel> _getFilteredValidations() {
    return _validations.where((validation) {
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch =
          validation.name.toLowerCase().contains(searchTerm) ||
              validation.assetType.toLowerCase().contains(searchTerm);
      final matchesFilter =
          _selectedFilter == 'All' || validation.assetType == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Revaluation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadValidations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(child: _buildValidationList()),
              ],
            ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search assets...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Asset Type',
                border: OutlineInputBorder(),
              ),
              items: ['All', 'Land', 'House'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedFilter = newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationList() {
    final filteredValidations = _getFilteredValidations();

    if (filteredValidations.isEmpty) {
      return const Center(
        child: Text('No validated assets found'),
      );
    }

    return ListView.builder(
      itemCount: filteredValidations.length,
      itemBuilder: (context, index) {
        final validation = filteredValidations[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(validation.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${validation.assetType}'),
                Text(
                    'Validated: ${_dateFormat.format(validation.valuationDate)}'),
                Text(
                    'Cost: ETB ${_currencyFormat.format(validation.totalCostBuilding)}'),
                Text('Status: ${validation.valuationStatus}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _navigateToRevaluation(validation),
              tooltip: 'Revaluate',
            ),
          ),
        );
      },
    );
  }

  void _navigateToRevaluation(ValidatedDataModel validation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RevaluationScreen(
          previousValidation: validation,
        ),
      ),
    ).then((_) => _loadValidations()); // Refresh list after revaluation
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
