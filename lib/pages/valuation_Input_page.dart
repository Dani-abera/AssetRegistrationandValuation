// import 'package:flutter/material.dart';
// import 'package:land_house_verify/model/validated_data_model.dart';
//
// class AssetValuationForm extends StatefulWidget {
//   @override
//   _AssetValuationFormState createState() => _AssetValuationFormState();
// }
//
// class _AssetValuationFormState extends State<AssetValuationForm> {
//   final _formKey = GlobalKey<FormState>();
//   late String _assetName;
//   late String _valuatorName;
//   late String _valuationExecutor;
//   late String _assetType;
//   late String _valuationMethod;
//   late DateTime _valuationDate;
//   late double _memlcFactor;
//   late double _currencyFactor;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Asset Valuation Form'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Asset Name'),
//                 onSaved: (value) => _assetName = value!,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter asset name' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Valuator Name'),
//                 onSaved: (value) => _valuatorName = value!,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter valuator name' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Valuation Executor'),
//                 onSaved: (value) => _valuationExecutor = value!,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter valuation executor' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Asset Type'),
//                 onSaved: (value) => _assetType = value!,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter asset type' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Valuation Method'),
//                 onSaved: (value) => _valuationMethod = value!,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter valuation method' : null,
//               ),
//               // Additional input fields for the valuation factors, construction costs, etc.
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'MEMLC Factor'),
//                 keyboardType: TextInputType.number,
//                 onSaved: (value) => _memlcFactor = double.parse(value!),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter MEMLC factor' : null,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Currency Factor'),
//                 keyboardType: TextInputType.number,
//                 onSaved: (value) => _currencyFactor = double.parse(value!),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter currency factor' : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();
//                     // Process the data
//                     final asset = ValidatedDataModel(
//                       name: _assetName,
//                       valuatorName: _valuatorName,
//                       valuationExecutor: _valuationExecutor,
//                       assetType: _assetType,
//                       valuationMethod: _valuationMethod,
//                       constructionCosts: [],
//                       buildingRelatedCosts: [],
//                       totalCostBuildingConstruction: 0.0,
//                       totalBuildingRelatedCost: 0.0,
//                       totalCostBuilding: 0.0,
//                       valuationStatus: 'First valuation',
//                       valuationDate: DateTime.now(),
//                       memlcFactor: _memlcFactor,
//                       currencyFactor: _currencyFactor,
//                       totalCostAfterRevaluation: 0.0,
//                       id: '1',
//                     );
//                     print('Asset Valuation Data: $asset');
//                   }
//                 },
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
