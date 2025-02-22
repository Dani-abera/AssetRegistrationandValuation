import 'package:flutter/material.dart';

class SingleRoomEvaluation extends StatefulWidget {
  final String assetName;
  final String roomId;
  final String assetTotalArea;
  final String assetTotalCost;
  final String roomTotalArea;

  const SingleRoomEvaluation({
    super.key,
    required this.assetName,
    required this.roomId,
    required this.assetTotalArea,
    required this.assetTotalCost,
    required this.roomTotalArea,
  });

  @override
  State<SingleRoomEvaluation> createState() => _SingleRoomEvaluationState();
}

class _SingleRoomEvaluationState extends State<SingleRoomEvaluation> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for basic information
  final _nameController = TextEditingController();
  final _valuatorNameController = TextEditingController();
  final _valuationExecutorController = TextEditingController();

  double _calculateRoomCost() {
    double assetTotalArea = double.tryParse(widget.assetTotalArea) ?? 1.0;
    double assetTotalCost = double.tryParse(widget.assetTotalCost) ?? 0.0;
    double roomTotalArea = double.tryParse(widget.roomTotalArea) ?? 0.0;

    double costPerSquareMeter = assetTotalCost / assetTotalArea;
    return costPerSquareMeter * roomTotalArea;
  }
  double _calculateCostPerSquarMeter() {
    double assetTotalArea = double.tryParse(widget.assetTotalArea) ?? 1.0;
    double assetTotalCost = double.tryParse(widget.assetTotalCost) ?? 0.0;
    double roomTotalArea = double.tryParse(widget.roomTotalArea) ?? 0.0;

    double costPerSquareMeter = assetTotalCost / assetTotalArea;
    return costPerSquareMeter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Room Evaluation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInformation(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      elevation: 4,
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
            Text("Asset Name: ${widget.assetName}"),
            Text("Room ID: ${widget.roomId}"),
            Text("Asset Total Area: ${widget.assetTotalArea} m²"),
            Text("Asset Total Cost: ${widget.assetTotalCost}"),
            Text("Room Total Area: ${widget.roomTotalArea} m²"),
            const SizedBox(height: 10),
            Text(
              "Hint: \n Cost per 1m² = Asset Total Cost ÷ Asset Total Area\n"
                  "Cost per 1m² = ${_calculateCostPerSquarMeter().toStringAsFixed(2)} \n "
                  "\n Room Total Cost = Cost per 1m² × Room Total Area"
                  "\n Room Total Cost = ${_calculateCostPerSquarMeter().toStringAsFixed(2)} × ${widget.roomTotalArea}",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Room Total Cost: ${_calculateRoomCost().toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
