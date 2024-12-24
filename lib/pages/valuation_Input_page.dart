import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ValuationInputPage extends StatefulWidget {
  final String assetId;
  const ValuationInputPage({Key? key, required this.assetId}) : super(key: key);

  @override
  _ValuationInputPageState createState() => _ValuationInputPageState();
}

class _ValuationInputPageState extends State<ValuationInputPage> {
  final _formKey = GlobalKey<FormState>();
  String valuatorName = '';
  String valuationMethod = 'Market Approach';
  double valuationAmount = 0.0;

  Future<void> submitValuation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseFirestore.instance
          .collection('assets')
          .doc(widget.assetId)
          .collection('valuations')
          .add({
        'valuatorName': valuatorName,
        'valuationMethod': valuationMethod,
        'valuationAmount': valuationAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Valuation submitted successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Valuation Input')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Valuator Name'),
                onSaved: (value) => valuatorName = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter valuator name' : null,
              ),
              DropdownButtonFormField(
                value: valuationMethod,
                items: ['Market Approach', 'Income Approach', 'Cost Approach']
                    .map((method) =>
                        DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (value) => setState(() => valuationMethod = value!),
                decoration: InputDecoration(labelText: 'Valuation Method'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Valuation Amount'),
                keyboardType: TextInputType.number,
                onSaved: (value) => valuationAmount = double.parse(value!),
                validator: (value) =>
                    value!.isEmpty ? 'Enter valuation amount' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitValuation,
                child: Text('Submit Valuation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
